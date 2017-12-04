// #ifdef DIRECT_MEX_BUILD
// #include <assert.h>
// #else
// #include "stdafx.h"
// #endif

#include "stdafx.h"
#include "TifWriter.h"
#include <string>

/*
TIFWRITER IMPLEMENTATION NOTES

This implementation is based on the TIFF spec revision 6.0, see eg 
http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf.


* Overall structure of TIFWriter TIFF file. Both header and frames
have tail-padding, or tail-nonsense bytes. The header is as
described in the TIFF spec.

TIFF header  Chan1Frame1 Chan2Frame1  ...  ChanNFrame1  ...  ChanNFrameM
|------------|-----------|-----------|-   -|-----------|-   -|-----------|


* Structure of a Frame. IFD, SuppIFD, and ImageData are all padded
to be consistent with TifWriter:fFrameOffsets. The SuppIFD
contains TIFF header info that is offset (too large to fit
directly in the IFD, eg the image description). Image Data
contains the actual image pixels.

IFD   SuppIFD     Image Data
|-----|---------|------------------|

*/  

// used for padding
static const char ZEROS[8] = {0,0,0,0,0,0,0,0};

TifWriter::TifWriter(void) :
fImageWidth(0),
fImageLength(0),
fBytesPerPixel(0),
fNumChannels(0),
fRowsPerStrip(0),
fSuppIFD(NULL),
fSuppIFDSize(0),
fTiffFH(NULL)
{
  fSuppIFDOffsets.XResolution = 0;
  fSuppIFDOffsets.YResolution = 0;
  fSuppIFDOffsets.ImageDescription = 0;
  fSuppIFDOffsets.StripOffsets = 0;
  fSuppIFDOffsets.StripByteCounts = 0;

  fFrameOffsets.SuppIFD = 0;
  fFrameOffsets.ImageData = 0;
  fFrameOffsets.NextIFD = 0;

  // The TIFF spec specifies various field sizes in numbers of bytes;
  // these asserts ensure that we comply with the spec
  assert(sizeof(char)==1); // maybe guaranteed by C++ (?)
  assert(sizeof(unsigned short)==2);
  assert(sizeof(unsigned int)==4);
}

TifWriter::~TifWriter() {
  if (isTifFileOpen()) {
    closeTifFile();
  }
  assert(fTiffFH==NULL);
  if (fSuppIFD!=NULL){
    delete[] fSuppIFD;
    fSuppIFD = NULL;
  }
}

bool TifWriter::isTifFileOpen(void) const {
  return (fTiffFH!=NULL);
}

void TifWriter::closeTifFile(void) {
  if (fTiffFH!=NULL) {
    long int pos = ftell(fTiffFH);
    unsigned int upos = pos;
    if (upos!=TifWriter::FIRSTIFDFILEOFFSET) {
      // a file is open, and the file ptr is not at the first ifd
      // offset. that means that at least one frame has been written.

      long int x = fFrameOffsets.NextIFD;
      x *= -1;
      x += 2+TifWriter::NUMFIELDS*TifWriter::DIRENTRYSIZE;
      int ecode = fseek(fTiffFH,x,SEEK_CUR); //For long file spport, will need to replace with 64-bit version, e.g. _fseeki64. That alone is insufficient though. Probably need to replace fopen as well.      
      if (ecode!=0) {
        handleErr("Error fseeking to last IFD.");
      }
      writeToFile(&(ZEROS[0]),sizeof(unsigned int),1);
    }

    fclose(fTiffFH);
    fTiffFH = NULL;
  }
}

bool TifWriter::openTifFile(const char *fname, const char *modestr) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  if (isTifFileOpen()) {
    closeTifFile();
  }
  if (fopen_s(&fTiffFH,fname,modestr)==0) {

    // 'II'
    char tmp = 'I';
    writeToFile(&tmp,sizeof(char),1);
    writeToFile(&tmp,sizeof(char),1);

    // 42
    unsigned short fortytwo = 42;
    writeToFile(&fortytwo,sizeof(unsigned short),1);

    // first IFD
    writeToFile(&TifWriter::FIRSTIFDFILEOFFSET,sizeof(unsigned int),1);

    int ecode = fseek(fTiffFH,TifWriter::FIRSTIFDFILEOFFSET,SEEK_SET);
    if (ecode!=0) {
      handleErr("Error fseeking to first IFD.");
    }

    return true;
  }
  return false;
}

void TifWriter::configureImage(unsigned short imWidth, 
                               unsigned short imLength, 
                               unsigned short bytesPerPixel,
                               unsigned short numChannels, 
                               bool signedData,
                               const char *imageDescription,
                               unsigned int targetBytesPerFullStrip) {
#ifdef TIFWRITER_DBG
                                 mexPrintf("%s\n",__FUNCTION__);
#endif
                                 CONSOLETRACE();
                                 assert(imWidth>0);
                                 assert(imLength>0);
                                 assert(bytesPerPixel>0);
                                 assert(numChannels>0);
                                 assert(targetBytesPerFullStrip>0);

                                 fImageWidth = imWidth;
                                 fImageLength = imLength;
                                 fBytesPerPixel = bytesPerPixel;
                                 fNumChannels = numChannels;
                                 fRowsPerStrip = targetBytesPerFullStrip/getBytesPerRow(); // integer divide

                                 if (signedData == true) {
                                   fSampleFormat = 2;
                                 } else {
                                   fSampleFormat = 1;
                                 } 

                                 if (fRowsPerStrip < 1) {
                                   handleErr("There must be at least one row per strip.");
                                 }

                                 this->updateImageDescription(imageDescription);

                                 setupIFD();
}

void 
TifWriter::updateImageDescription(const char *imageDescription)
{
  if (imageDescription==NULL)
    imageDescription = "default image description";	  

  fImageDescription = imageDescription;

  if (fImageDescription.length() < 2) {
    // Pad the image description, because at the moment the imagedesc
    // is always offset into the supplementary IFD. This requires that
    // the description be longer than one character. (Actually the
    // terminating newline probably suffices, but just to be safe...)
    fImageDescription += "##";
  }
}

void 
TifWriter::replaceImageDescription(const char *imageDescription)
{
  assert(imageDescription != NULL);
  this->updateImageDescription(imageDescription);
  setupIFD();
}

void TifWriter::modifyImageDescription(unsigned int loc, const char *buf, unsigned int len)
{
  assert(loc<fImageDescription.length());
  len = min(len,fImageDescription.length()-loc);
  fImageDescription.replace(loc,len,buf,len);
  memcpy(fSuppIFD+fSuppIFDOffsets.ImageDescription+loc,buf,len);
}

void TifWriter::handleErr(const char *msg) const {
  std::string errmsg("TifWriter error: ");
  if (msg!=NULL) { 
    errmsg += msg;
  }
  mexPrintf(errmsg.c_str());
}

void TifWriter::putDirectoryEntryShort(void *loc,
                                       unsigned short tag,
                                       unsigned short type,
                                       unsigned int count,
                                       unsigned short value) {
#ifdef TIFWRITER_DBG
                                         mexPrintf("%s\n",__FUNCTION__);
#endif
                                         char *p = (char*)loc;

                                         memcpy(p,&tag,sizeof(unsigned short));
                                         p += sizeof(unsigned short);
                                         memcpy(p,&type,sizeof(unsigned short));
                                         p += sizeof(unsigned short);
                                         memcpy(p,&count,sizeof(unsigned int));
                                         p += sizeof(unsigned int);
                                         memcpy(p,&value,sizeof(unsigned short));
                                         p += sizeof(unsigned short);

                                         unsigned short tmp = 0;
                                         memcpy(p,&tmp,sizeof(unsigned short));
}

void TifWriter::putDirectoryEntryWithOffset(void *loc,
                                            unsigned short tag,
                                            unsigned short type,
                                            unsigned int count,
                                            unsigned int value) {
#ifdef TIFWRITER_DBG
                                              mexPrintf("%s\n",__FUNCTION__);
#endif
                                              char *p = (char*)loc;

                                              memcpy(p,&tag,sizeof(unsigned short));
                                              p += sizeof(unsigned short);
                                              memcpy(p,&type,sizeof(unsigned short));
                                              p += sizeof(unsigned short);
                                              memcpy(p,&count,sizeof(unsigned int));
                                              p += sizeof(unsigned int);
                                              memcpy(p,&value,sizeof(unsigned int));
}

void TifWriter::setupIFD(void) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  /////////
  // IFD //
  /////////

  // number of directory entries
  unsigned short numdirs = TifWriter::NUMFIELDS;
  memcpy(&(fIFD[0]),&numdirs,sizeof(unsigned short));

  putDirectoryEntryShort(&(fIFD[2+TifWriter::ImageWidthField*TifWriter::DIRENTRYSIZE]),
    256, // Tag value here and in the following
    // are taken directly from TIFF
    // spec. Could create an enum, but these
    // "magic numbers" only appear here in
    // this function, so seems fine as-is.
    TifWriter::SHORTTIFFTYPE,
    1,
    fImageWidth);
  putDirectoryEntryShort(&(fIFD[2+TifWriter::ImageLengthField*TifWriter::DIRENTRYSIZE]),
    257,
    TifWriter::SHORTTIFFTYPE,
    1,
    fImageLength);
  putDirectoryEntryShort(&(fIFD[2+TifWriter::BitsPerSampleField*TifWriter::DIRENTRYSIZE]),
    258,
    TifWriter::SHORTTIFFTYPE,
    1,
    fBytesPerPixel*8);
  putDirectoryEntryShort(&(fIFD[2+TifWriter::CompressionField*TifWriter::DIRENTRYSIZE]),
    259,
    TifWriter::SHORTTIFFTYPE,
    1,
    1); // no compression
  putDirectoryEntryShort(&(fIFD[2+TifWriter::PhotometricInterpretationField*TifWriter::DIRENTRYSIZE]),
    262,
    TifWriter::SHORTTIFFTYPE,
    1,
    1); // black is zero
  putDirectoryEntryShort(&(fIFD[2+TifWriter::RowsPerStripField*TifWriter::DIRENTRYSIZE]),
    278,
    TifWriter::SHORTTIFFTYPE,
    1,
    fRowsPerStrip);
  putDirectoryEntryShort(&(fIFD[2+TifWriter::ResolutionUnitField*TifWriter::DIRENTRYSIZE]),
    296,
    TifWriter::SHORTTIFFTYPE,
    1,
    2); // inches
  putDirectoryEntryShort(&(fIFD[2+TifWriter::OrientationField*TifWriter::DIRENTRYSIZE]),
    274,
    TifWriter::SHORTTIFFTYPE,
    1,
    1); // 0th row is visual top, 0th col is visual left
  putDirectoryEntryShort(&(fIFD[2+TifWriter::SamplesPerPixelField*TifWriter::DIRENTRYSIZE]),
    277,
    TifWriter::SHORTTIFFTYPE,
    1,
    1); // grayscale
  putDirectoryEntryShort(&(fIFD[2+TifWriter::PlanarConfigurationField*TifWriter::DIRENTRYSIZE]),
    284,
    TifWriter::SHORTTIFFTYPE,
    1,
    1); // 'chunky' (irrelevant since numSamplesPerPixel=1)
  putDirectoryEntryShort(&(fIFD[2+TifWriter::SampleFormatField*TifWriter::DIRENTRYSIZE]),
    339,
    TifWriter::SHORTTIFFTYPE,
    1,
    fSampleFormat); // either unsigned or signed 2's complement

  //////////////////////
  // Supplemental IFD //
  //////////////////////

  unsigned int sizeOfSupplementalIFD = 0;

  putDirectoryEntryWithOffset(&(fIFD[2+TifWriter::XResolutionField*TifWriter::DIRENTRYSIZE]),
    282,
    TifWriter::RATIONALTIFFTYPE,
    1,
    0); // value is irrelevant, will be overwritten later
  fSuppIFDOffsets.XResolution = sizeOfSupplementalIFD;
  sizeOfSupplementalIFD += 2*sizeof(unsigned int); // RATIONAL type is 2*LONG

  putDirectoryEntryWithOffset(&(fIFD[2+TifWriter::YResolutionField*TifWriter::DIRENTRYSIZE]),
    283,
    TifWriter::RATIONALTIFFTYPE,
    1,
    0);
  fSuppIFDOffsets.YResolution = sizeOfSupplementalIFD;
  sizeOfSupplementalIFD += 2*sizeof(unsigned int); // RATIONAL type is 2*LONG

  putDirectoryEntryWithOffset(&(fIFD[2+TifWriter::ImageDescriptionField*TifWriter::DIRENTRYSIZE]),
    270,
    TifWriter::ASCIITIFFTYPE,
    (unsigned int) fImageDescription.length()+1,
    0);
  fSuppIFDOffsets.ImageDescription = sizeOfSupplementalIFD;
  sizeOfSupplementalIFD += ((unsigned int) fImageDescription.length()+1)*sizeof(char); //std::string::length() does not account for nul-terminate

  if (getStripsPerFrame()==1) {
    // stripOffsets, stripByteCounts can be stored directly in IFD.
    fStripOffsetsAndStripByteCountsAreInIFD = true;

    putDirectoryEntryShort(&(fIFD[2+TifWriter::StripOffsetsField*TifWriter::DIRENTRYSIZE]),
      273,
      TifWriter::LONGTIFFTYPE,
      getStripsPerFrame(),
      0); // irrelevant value, will be set later
    fSuppIFDOffsets.StripOffsets = 0; // set to arbitrary value; should be unused

    putDirectoryEntryShort(&(fIFD[2+TifWriter::StripByteCountsField*TifWriter::DIRENTRYSIZE]),
      279,
      TifWriter::LONGTIFFTYPE,
      getStripsPerFrame(),
      getBytesPerFrame());
    fSuppIFDOffsets.StripByteCounts = 0; // set to arbitrary value; should be unused

  } else if (getStripsPerFrame()>1) {
    // stripOffsets, stripByteCounts need to be stored in SuppIFD.
    fStripOffsetsAndStripByteCountsAreInIFD = false;

    putDirectoryEntryWithOffset(&(fIFD[2+TifWriter::StripOffsetsField*TifWriter::DIRENTRYSIZE]),
      273,
      TifWriter::LONGTIFFTYPE,
      getStripsPerFrame(),
      0); // irrelevant value, will be set later
    fSuppIFDOffsets.StripOffsets = sizeOfSupplementalIFD;
    sizeOfSupplementalIFD += getStripsPerFrame()*sizeof(unsigned int);

    putDirectoryEntryWithOffset(&(fIFD[2+TifWriter::StripByteCountsField*TifWriter::DIRENTRYSIZE]),
      279,
      TifWriter::LONGTIFFTYPE,
      getStripsPerFrame(),
      0); // irrelevant value, will be set later
    fSuppIFDOffsets.StripByteCounts = sizeOfSupplementalIFD;
    sizeOfSupplementalIFD += getStripsPerFrame()*sizeof(unsigned int);
  }

  fSuppIFDSize = sizeOfSupplementalIFD;

  //// Initialize SuppIFD.

  if (fSuppIFD!=NULL) {
    delete[] fSuppIFD;
    fSuppIFD = NULL;
  }
  fSuppIFD = new char[fSuppIFDSize];
  if (fSuppIFD==NULL) {
    handleErr("Problem allocating supplementary IFD.");
  }

  // Fill in offset/supplemental data. 

  unsigned int resNum = 72*16*16*16*16*16*16;
  unsigned int resDen = 1*16*16*16*16*16*16;  
  memcpy(fSuppIFD+fSuppIFDOffsets.XResolution,&resNum,sizeof(unsigned int));
  memcpy(fSuppIFD+fSuppIFDOffsets.XResolution+sizeof(unsigned int),&resDen,sizeof(unsigned int));
  memcpy(fSuppIFD+fSuppIFDOffsets.YResolution,&resNum,sizeof(unsigned int));
  memcpy(fSuppIFD+fSuppIFDOffsets.YResolution+sizeof(unsigned int),&resDen,sizeof(unsigned int));

  memcpy(fSuppIFD+fSuppIFDOffsets.ImageDescription,fImageDescription.c_str(),
    (fImageDescription.length()+1)*sizeof(char));

  if (!fStripOffsetsAndStripByteCountsAreInIFD) {
    // Initialize strip offsets in supp IFD (irrelevant, will be updated later)
    unsigned int numStrips = getStripsPerFrame();
    for (unsigned int c=0;c<numStrips;++c) {
      unsigned int val = 0;
      memcpy(fSuppIFD+fSuppIFDOffsets.StripOffsets+c*sizeof(unsigned int),&val,sizeof(unsigned int));
    }

    // strip bytecounts
    unsigned int numFullStrips = getNumFullStripsPerFrame();
    unsigned int bytesPerFullStrip = getBytesPerFullStrip();
    unsigned int sizeFinalStrip = getBytesPerFrame() % bytesPerFullStrip;
    for (unsigned int c=0;c<numFullStrips;++c) {
      memcpy(fSuppIFD+fSuppIFDOffsets.StripByteCounts+c*sizeof(unsigned int),
        &bytesPerFullStrip,sizeof(unsigned int));
    }
    if (sizeFinalStrip>0) {
      assert(getStripsPerFrame() > getNumFullStripsPerFrame());
      memcpy(fSuppIFD+fSuppIFDOffsets.StripByteCounts+numFullStrips*sizeof(unsigned int),
        &sizeFinalStrip,sizeof(unsigned int));
    }
  }

  //// Initialize file offsets. These values are the offsets in the
  //// tiff file of the suppIFD and image data relative to byte 0 of
  //// the IFD. The point of the computations here is that we place the
  //// suppIFD and image data at 8-byte boundaries (for no real reason).
  unsigned int IFDBlocksOfEight = (TifWriter::IFDSIZE+7)/8;
  fFrameOffsets.SuppIFD = IFDBlocksOfEight*8;

  unsigned int TotalIFDSize = fFrameOffsets.SuppIFD + fSuppIFDSize;
  unsigned int TotalIFDBlocksOfEight = (TotalIFDSize+7)/8;
  fFrameOffsets.ImageData = TotalIFDBlocksOfEight*8;

  unsigned int TotalSubfileSize = fFrameOffsets.ImageData + getBytesPerFrame();
  unsigned int TotalSubfileBlocksOfEight = (TotalSubfileSize+7)/8;
  fFrameOffsets.NextIFD = TotalSubfileBlocksOfEight*8;
}

void TifWriter::updateOffsetsInIFDAndSuppIFD(unsigned int IFDFileOffset) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  assert(IFDFileOffset>=0);

  unsigned int actualSuppIFDFileOffset = IFDFileOffset + fFrameOffsets.SuppIFD;

  // update offsets in IFD
  unsigned int offset = actualSuppIFDFileOffset + fSuppIFDOffsets.XResolution;
  memcpy(fIFD+2+TifWriter::XResolutionField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
    &offset,
    sizeof(unsigned int));

  offset = actualSuppIFDFileOffset + fSuppIFDOffsets.YResolution;
  memcpy(fIFD+2+TifWriter::YResolutionField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
    &offset,
    sizeof(unsigned int));

  offset = actualSuppIFDFileOffset + fSuppIFDOffsets.ImageDescription;
  memcpy(fIFD+2+TifWriter::ImageDescriptionField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
    &offset,
    sizeof(unsigned int));

  if (!fStripOffsetsAndStripByteCountsAreInIFD) {
    offset = actualSuppIFDFileOffset + fSuppIFDOffsets.StripOffsets;
    memcpy(fIFD+2+TifWriter::StripOffsetsField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
      &offset,
      sizeof(unsigned int));

    offset = actualSuppIFDFileOffset + fSuppIFDOffsets.StripByteCounts;
    memcpy(fIFD+2+TifWriter::StripByteCountsField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
      &offset,
      sizeof(unsigned int));
  }

  // update offset of next IFD
  offset = IFDFileOffset + fFrameOffsets.NextIFD;
  memcpy(fIFD+2+TifWriter::NUMFIELDS*TifWriter::DIRENTRYSIZE,
    &offset,
    sizeof(unsigned int));

  // update strip offsets
  unsigned int numStrips = getStripsPerFrame();
  for (unsigned int c=0;c<numStrips;++c) {
    unsigned int stripFileOffset 
      = IFDFileOffset + fFrameOffsets.ImageData + c*getBytesPerFullStrip();

    if (fStripOffsetsAndStripByteCountsAreInIFD) {
      assert(c==0); // should only be one strip
      memcpy(fIFD+2+TifWriter::StripOffsetsField*TifWriter::DIRENTRYSIZE+TifWriter::VALUEOFFSETINFIELD,
        &stripFileOffset,
        sizeof(unsigned int));
    } else {
      memcpy(fSuppIFD+fSuppIFDOffsets.StripOffsets+c*sizeof(unsigned int),
        &stripFileOffset,
        sizeof(unsigned int));
    }
  }

}

void TifWriter::writeToFile(const void* buf, size_t sz, size_t cnt) {
  size_t n = fwrite(buf,sz,cnt,fTiffFH);
  if (n<cnt) {
    handleErr("Error writing to TIFF file.");
  }
}

void TifWriter::writeIFD(void) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  writeToFile(&(fIFD[0]),sizeof(char),TifWriter::IFDSIZE);

  unsigned int numPadBytes = fFrameOffsets.SuppIFD - TifWriter::IFDSIZE;
  writeToFile(&(ZEROS[0]),sizeof(char),numPadBytes);

  writeToFile(fSuppIFD,sizeof(char),fSuppIFDSize);
  numPadBytes = fFrameOffsets.ImageData - (fFrameOffsets.SuppIFD + fSuppIFDSize);
  writeToFile(&(ZEROS[0]),sizeof(char),numPadBytes);

  // file pointer now at start of ImageData for this frame
}

// this writes a single frame at the current file location. it is
// assumed that the previous ifd already has its offset-to-next-ifd
// pointing at the current file location.
void TifWriter::writeSingleFrame(const char *imageBuf, unsigned int sz) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  assert(imageBuf!=NULL);
  assert(sz==getBytesPerFrame());

  long int pos = ftell(fTiffFH);
  unsigned int upos = pos;

  updateOffsetsInIFDAndSuppIFD(upos);

  writeIFD();

  writeToFile(imageBuf,sizeof(char),sz);

  unsigned int numPadBytes = fFrameOffsets.NextIFD - (fFrameOffsets.ImageData + sz);
  writeToFile(&(ZEROS[0]),sizeof(char),numPadBytes);
}

void TifWriter::writeFramesForAllChannels(const char *buf, unsigned int sz) {
#ifdef TIFWRITER_DBG
  mexPrintf("%s\n",__FUNCTION__);
#endif

  unsigned int bpf = getBytesPerFrame();
  assert(sz>=fNumChannels*bpf);
  const char *p = buf;

  for (unsigned short c=0;c<fNumChannels;++c) {
    writeSingleFrame(p,bpf);
    p += bpf;
  }
}

void TifWriter::writeTestFile(void) {
  // simple test with two iamges

  char im1[37*56*1];
  char im2[99*88*2*3]; // 2 bytes/pixel, 3 frames

  for (int i=0;i<37*56;i++) {
    im1[i] = (char) (i%3)*50;
  }

  unsigned short *p = (unsigned short *) &(im2[0]);
  for (int i=0;i<99*88;++i) {
    *p = (i%2)*10000;
    p++;
  }
  for (int i=0;i<99*88;++i) {
    *p = (i%3)*10000;
    p++;
  }
  for (int i=0;i<99*88;++i) {
    *p = (i%4)*10000;
    p++;
  }


  TifWriter tw;
  //   tw.openTifFile("image1.tif");
  //   tw.configureImage(37,56,1,1,NULL,1400);
  //   tw.writeFramesForAllChannels(&(im1[0]),37*56);
  //   tw.closeTifFile();

  //   tw.openTifFile("image2.tif");
  //   tw.configureImage(99,88,2,3,NULL,8000);
  //   tw.writeFramesForAllChannels(&(im2[0]),99*88*2*3);
  //   tw.closeTifFile();

  tw.openTifFile("image12.tif");
  tw.configureImage(37,56,1,1,false,"12345678901234567890",1400);
  tw.writeFramesForAllChannels(&(im1[0]),37*56);
  tw.writeFramesForAllChannels(&(im1[0]),37*56);
  tw.closeTifFile();

  const char *buf = "abcdefghijklmnopqrstuvwxyz";

  tw.openTifFile("imageDescTest.tif");
  tw.configureImage(37,56,1,1,false,"12345678901234567890",1400);
  tw.writeFramesForAllChannels(&(im1[0]),37*56);
  tw.modifyImageDescription(5,buf,3);
  tw.writeFramesForAllChannels(&(im1[0]),37*56);
  tw.modifyImageDescription(0,buf,2);
  tw.writeFramesForAllChannels(&(im1[0]),37*56);
  tw.configureImage(99,88,2,3,false,"desc2desc2desc2",8000);
  tw.modifyImageDescription(10,buf,10);
  tw.writeFramesForAllChannels(&(im2[0]),99*88*2*3);
  tw.configureImage(99,88,2,3,false,"desc2desc2desc2",8000);
  tw.writeFramesForAllChannels(&(im2[0]),99*88*2*3);  
  tw.closeTifFile();
}


// void TifWriter::writeTestFile(void) {

// 	const unsigned int N = 512*512*2*2;
// 	char buf[N];
// 	for (unsigned int c=0;c<N;++c) buf[c] = (char)c;

// 	const unsigned int chunkexponent = 8;
// 	const unsigned int chunksize = power(2,chunkexponent);
// 	const unsigned int numchunks = N/chunksize;
// 	char datafilename[100];
// 	char perffilename[100];

// 	mexPrintf("exponent size numchunks %d %d %d\n", chunkexponent, chunksize, numchunks);

// 	sprintf(datafilename,"%s%d","flush_data",chunkexponent);
// 	sprintf(perffilename,"%s%d","flush_perf",chunkexponent);
// 	FILE *fdata, *fperf;
// 	fopen_s(&fdata,datafilename,"wbn");
// 	fopen_s(&fperf,perffilename,"w");

// 	const unsigned int NRUN = 1000;
// 	for (unsigned int c=0;c<NRUN;++c) {
// 		LARGE_INTEGER pcTic11,  pcToc11, pcFreq11;
// 		QueryPerformanceFrequency(&pcFreq11);
// 		LONGLONG pcDiff11;
// 		QueryPerformanceCounter(&pcTic11);
// 	/*	
// 		for (int z=0;z<8;z++) {
// 			fwrite(&z,sizeof(char),1,fdata);
// 		}*/

// 		char *p = &(buf[0]);
// 		for (unsigned int d=0;d<numchunks;++d) {
// 			fwrite(p,sizeof(char),chunksize,fdata);
// 			fflush(fdata);
// 			p+=chunksize;
// 		}

// 		QueryPerformanceCounter(&pcToc11);
// 		pcDiff11 = pcToc11.QuadPart-pcTic11.QuadPart;
// 		fprintf(fperf, "%.16g %lld\n",((float)pcDiff11/(float)pcFreq11.QuadPart), pcDiff11);
// 	}

// 	fclose(fdata);
// 	fclose(fperf);
// }











// Old, from LibTiff days

// void TifWriter::writeFieldData(void) {
//   assert(isTifFileOpen());
//   assert(fImageWidth>0); // proxy to indicate that configure() has been called
// #ifdef TIFWRITER_DBG
// 	fprintf(fDbgFH,"writeFieldData\n");
// #endif

//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_IMAGEWIDTH, fImageWidth));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_IMAGELENGTH, fImageLength));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_BITSPERSAMPLE, fBytesPerPixel*8));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_COMPRESSION, COMPRESSION_NONE));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK));  
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_ROWSPERSTRIP, fRowsPerStrip));
//   // StripByteCount not in libtiff, but required by TIFF spec. Assume libtiff will figure this out based on compression.
//   //errHandler(TIFFSetField(fTiffFH, TIFFTAG_STRIPBYTECOUNT, rps)); 

//   // resolution
//   const int BOGUS_VALUE_TO_MEET_APPARENT_TIFF_REQUIREMENT = 72;
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_XRESOLUTION, BOGUS_VALUE_TO_MEET_APPARENT_TIFF_REQUIREMENT));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_YRESOLUTION, BOGUS_VALUE_TO_MEET_APPARENT_TIFF_REQUIREMENT));
//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_RESOLUTIONUNIT, RESUNIT_INCH));

//   errHandler(TIFFSetField(fTiffFH, TIFFTAG_IMAGEDESCRIPTION, fImageDescription));  
// }


// void TifWriter::writeSingleFrame(const char *buf, uint32 sz) {
// #ifdef TIFWRITER_DBG
// 	fprintf(fDbgFH,"writeSingleFrame\n");
// #endif

//   assert(buf!=NULL);
//   assert(sz==getBytesPerFrame());

//   writeFieldData();

//   tsize_t bytesPerFullStrip = fRowsPerStrip*fBytesPerRow;
//   tsize_t numFullStrips = getBytesPerFrame()/bytesPerFullStrip;
//   assert(numFullStrips == fImageLength/fRowsPerStrip);
//   tsize_t sizeFinalStrip = getBytesPerFrame() % bytesPerFullStrip;

//   const char *p = buf;
//   for (uint32 stripCounter=0;stripCounter<numFullStrips;stripCounter++) {
//     writeStrip(stripCounter,p,bytesPerFullStrip);
//     p += bytesPerFullStrip;    
//   }

//   // write the final (probably incomplete) strip
//   if (sizeFinalStrip>0) {
// 	  writeStrip(numFullStrips,p,sizeFinalStrip);
//   }

//   int ecode = TIFFWriteDirectory(fTiffFH);
//   if (ecode!=1) {
//     mexErrMsgTxt("TifWriter writeSingleFrame error.\n");
//   }
//   TIFFFlush(fTiffFH);
// }


// // sizeof(char) must equal sizeof(tdata_t) which is sizeof(void*)
// void TifWriter::writeStrip(tstrip_t strip, const char *buf, tsize_t sz) {
// #ifdef TIFWRITER_DBG
// 	fprintf(fDbgFH,"writeStrip\n");
// #endif

//   int ecode = TIFFWriteRawStrip(fTiffFH, strip, (tdata_t) buf, sz);
//   if (ecode<0) {
//     mexErrMsgTxt("Tifwriter writeStrip error.\n");
//   }
// }

// void TifWriter::writeFramesForAllChannels(const char *buf, uint32 sz) {
//   assert(buf!=NULL);
//   assert(sz==getBytesPerFrame()*fNumChannels);

// #ifdef TIFWRITER_DBG
//   fprintf(fDbgFH,"writeFramesAllChan\n");
//   LARGE_INTEGER pcTic,  pcToc, pcFreq;
//   QueryPerformanceFrequency(&pcFreq);
//   LONGLONG pcDiff;
//   QueryPerformanceCounter(&pcTic);
// #endif


//   const char *p = buf;
//   uint32 bytesPerFrame = getBytesPerFrame();
//   for (uint32 channelCounter=0;channelCounter<fNumChannels;channelCounter++) {
//     writeSingleFrame(p,bytesPerFrame);
//     p += bytesPerFrame;
//   }

// #ifdef TIFWRITER_DBG
//   QueryPerformanceCounter(&pcToc);
//   pcDiff = pcToc.QuadPart-pcTic.QuadPart;
//   fprintf(fPerfFH, "42 %.16g %llu\n",((float)pcDiff/(float)pcFreq.QuadPart),pcDiff);
//   fflush(fPerfFH);
// #endif

// }


// void TifWriter::libTiffPerfTest(void) {
//   TifWriter tw("desc");

//   // set data
//   const unsigned int N = 512*512*2;
//   char buf[N];
//   for (unsigned int c=0;c<N;c++) {
//     buf[c] = (char) rand(); 
//   }

//   tw.openTifFile("tifperftest.tif");
//   tw.configureImage(512,512,2,1);

//   for (unsigned int c=0;c<1000;c++) {
//     tw.writeFramesForAllChannels(&(buf[0]),N);
//   }
//   tw.closeTifFile();
// }

