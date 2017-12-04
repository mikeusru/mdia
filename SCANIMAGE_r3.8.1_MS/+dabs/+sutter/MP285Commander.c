// MP285Commander.c
//
//  value = serial_getPosition(comPortstr, baudRate, timeout, command, numbers)
//
//  value: double array
//  value: 0 for no error or return values for 'c' (position) and 's' (status)
//  value: -1 for error. 
//  value; -2 for timeout error.
//  value; -4 for no message received.
//
//  comPortstr: string. Port name. 'COM1', 'COM2' et al.
//  badRate: double. Default is 9600.
//  timeout: double. Relevant only for char(3) and 'm'.
//
//  numbers: used for 'v' and 'm' commands. Specifies the movement and velocity.
//
// command: 'c' (get position) return position [x, y, z]
//          'v' (set velocity) return error
//          'm' (move to position specified in numbers) return error or 0 for no error
//          'ma' (move to position specified in numbers and read).
//          'n' (reset screen) no return
//          's' (get status) return status
//          'r' (reset hardware) no return
//          'f' --- not command. reading. return 1 if it reads CR.
//          char(3) (stop movement)
// When command is associated with 'a', the software will pause until it receives CR.
// useful only for command 'm' and maybe 'v'.
//

#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "mex.h"

#define serial_READ  0
#define serial_WRITE 1
#define serial_READ_only 2
#define serial_COMMAND_only 3



int receive_from_serial(HANDLE hSerial, 
        unsigned char *read_characters, int read_size, int timeout){
    
    int i, j;
    double time1;
    unsigned char tmp_buffer[64];
    DWORD bytes_read; 
    time_t start_t, end_t;
    int errorCode = 0;
            
    start_t = clock();
    
    for (i=0; i<1000; i++){
        if (ReadFile(hSerial, tmp_buffer, sizeof(tmp_buffer), &bytes_read, NULL)){     
            if (bytes_read > 0)
                    break;
        } else 
            return (-1);

        end_t = clock();
        time1 = (double)(end_t - start_t) / CLOCKS_PER_SEC;
        mexPrintf("Still reading: elapsed time: %f\n", time1);
        
        if (time1 > timeout) 
            return (-2);

    }  
        

        if ((int)bytes_read < read_size+1){
                //mexPrintf("Received string length is smaller than %d\n", read_size);
                if (tmp_buffer[0] == 48)
                    mexPrintf("Motor is moving...  %d\n", i);
          
                //for (i=0; i< (int) bytes_read; i++) mexPrintf("%d-", (int)tmp_buffer[i]);
                //mexPrintf("\n");
                return (-4);
        } else if (tmp_buffer[read_size] == '\r') {
            
                for (i=0; i< (int) bytes_read; i++) *read_characters++ = tmp_buffer[i];
                return (0);
                
        } else if (tmp_buffer[bytes_read - 1] == '\r') {
            
                mexPrintf("Return received\n");
                return (0);
                
        } else {
            
            //mexPrintf("Read Failed. Last byte not terminator!\n");
            //for (i=0; i< (int) bytes_read; i++) mexPrintf("%d-", (int)tmp_buffer[i]);
            mexPrintf("\n");
            return (-1);
        } 
        
  
}

int analyze_data (unsigned char *command_char, 
        unsigned char *tmp_buffer, int readSize, 
        int *outputSize, double *output_buffer)
{
    int i;
    double val;
     
    if (command_char[0] == 'c'){
        for (i=0; i<3; i++) {
            val = pow(256, 3) * (double)tmp_buffer[3+4*i] + pow(256, 2)*(double)tmp_buffer[2+4*i]
                    + 256*(double)tmp_buffer[1+4*i] + (double)tmp_buffer[4*i]; // val must be double!!
            if (val > pow(256, 4)/2)
                val = val - pow(256, 4);
            output_buffer[i] = val;
        }
        *outputSize = 3;
    } else {
        *outputSize = readSize;
        for (i=0; i<readSize; i++)
            output_buffer[i] = tmp_buffer[i];
    }
    
    return (0);
}

int receive_analyze_serial_data (
        HANDLE hSerial, unsigned char *tmp_buffer, 
        int readSize, double timeout, int command_mode,
        bool needReturnCR,
        char *commandChar, 
        int *outputSize, double *output_buffer)    
{
    
        unsigned char receive_buffer[64];
        double analyzed_buffer[64];
        int output_size = 0;
        int i;
        int errorCode = 0;
                        
        switch (command_mode) {
            case serial_READ:
            case serial_READ_only:
                //
                    errorCode = receive_from_serial(hSerial, &receive_buffer, 
                            readSize, timeout);
        
//                     for (i=0; i<readSize; i++)
//                         mexPrintf("%d-", receive_buffer[i]);
//                     mexPrintf("\n");
                    
                    if (errorCode == 0) {                        
                        errorCode = analyze_data (commandChar, receive_buffer, 
                                readSize, &output_size, &analyzed_buffer);
                        
//                       for (i=0; i<output_size; i++)
//                         mexPrintf("%d-", analyzed_buffer[i]);
                        
                        if (errorCode == 0){
                            
                            *outputSize = output_size;

                            for (i=0; i<output_size; i++)
                                output_buffer[i] = analyzed_buffer[i];
                        }
                    } 
                    
                    break;

            case serial_WRITE:
            case serial_COMMAND_only:
                
                    //If necessary, it waits for receiving "CR" or some other values.
                    if (needReturnCR & commandChar[1] == 'a'){
                        
                        readSize = 0; // Just to make sure.
                        errorCode = receive_from_serial(hSerial, 
                                &receive_buffer, readSize, timeout);
                        
                        for (i=0; i<readSize; i++)
                            output_buffer[i] = receive_buffer[i];
                        
                    }
                    
                    output_buffer[0] = (double) errorCode;
                    *outputSize = 1;
                    
                    break;
                    
            default:
                output_buffer[0] = (double) errorCode;
                *outputSize = 1;
        }
        
        return(errorCode);

}



int send_serial_command (HANDLE hSerial, unsigned char *bytes_to_send, bool CRafterCommand){    
    DWORD bytes_written; 
    char   CR[1] = "\r"; //CR
        if(!WriteFile(hSerial, bytes_to_send, 1, &bytes_written, NULL))
                return (-1);
        
        if (CRafterCommand){
            if (!WriteFile(hSerial, CR, 1, &bytes_written, NULL))
                    return (-1);   
        }
        return(0);
}
        
int send_serial_command_and_number (HANDLE hSerial, unsigned char *bytes_to_send, unsigned char *number_to_send, int input_size){    
    DWORD bytes_written; 
    char   CR[1] = "\r"; //CR
    //sned_serial_command (hSerial, bytes_to_send, false);
    if(!WriteFile(hSerial, bytes_to_send, 1, &bytes_written, NULL))
            return (-1);
    if(!WriteFile(hSerial, number_to_send, input_size, &bytes_written, NULL))
            return (-1);    
    if (!WriteFile(hSerial, CR, 1, &bytes_written, NULL))
            return (-1);
    return(0);

}

int send_serial_command_all(HANDLE hSerial, 
        unsigned char *bytes_to_send, int command_mode, 
        bool CRafterCommand, unsigned char *tmp_buffer, int inputSize)
{      
    int errorCode = 0;
    
    switch (command_mode){
        case serial_READ:
        case serial_COMMAND_only:
            errorCode = send_serial_command(hSerial, bytes_to_send, CRafterCommand);
            break;
        case serial_WRITE:
            errorCode = send_serial_command_and_number (hSerial, bytes_to_send, tmp_buffer, inputSize);
            break;
        default:
            errorCode = 0;
    }
    
    return(errorCode);
}

int open_serial_port (HANDLE *serial_handle, unsigned char *ComName, int baudRate) {        
    // Open the serial port number
    
    HANDLE hSerial;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0};
    
    hSerial = CreateFile(
    ComName, GENERIC_READ|GENERIC_WRITE, 0, NULL,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
    if (hSerial == INVALID_HANDLE_VALUE){
        mexPrintf("\nError: %s was not found\n", ComName);
        return (-1);
    } else {
        *serial_handle = hSerial;
    }
    
    // Set device parameters
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (GetCommState(hSerial, &dcbSerialParams) == 0){
        mexPrintf("Error getting device state\n");
        return (-2);
    }
    
    dcbSerialParams.BaudRate = CBR_9600;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT; // = 0
    dcbSerialParams.Parity = NOPARITY;
    
    switch (baudRate){
        case 19200: 
            dcbSerialParams.BaudRate = CBR_19200;
            break;
        case 4800:
            dcbSerialParams.BaudRate = CBR_4800;
            break;
        case 2400:
            dcbSerialParams.BaudRate = CBR_2400;
            break; 
        case 1200:
            dcbSerialParams.BaudRate = CBR_1200;
            break;
        default:     
            dcbSerialParams.BaudRate = CBR_9600;
            break;
    }

    if(SetCommState(hSerial, &dcbSerialParams) == 0){
        mexPrintf("Error setting device parameters\n");
        return (-3);
    }
    
    // Set COM port timeout settings
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    
    if(SetCommTimeouts(hSerial, &timeouts) == 0){
        mexPrintf("Error setting timeouts\n");
        return (-4);
    }
    
    return (0);
}        



int reading_input_value(char *bytes_to_send, const mxArray *ptr, 
        int nrhs, int valueInputID, unsigned char *tmp_buffer) {
//Return error    
    int i, j, k, vel;
    double *xyz;

    //Otherwise it can be crashed!!
    if (nrhs < valueInputID+1) {
        mexPrintf("Command %c requires values in double\n", bytes_to_send[0]);
        return (-1);
    }
    
    if (mxGetClassID(ptr) != mxDOUBLE_CLASS){
        mexPrintf("Command %c requires values in double\n", bytes_to_send[0]);
        return (-1);
    }
            
    switch (bytes_to_send[0]){
        case 'v':            
            vel = (int)mxGetScalar(ptr);
            if (vel > 255) {
                tmp_buffer[1] = 1;
                tmp_buffer[0] = vel - 256;
            } else {
                tmp_buffer[1] = 0;
                tmp_buffer[0] = vel;
            }
            //mexPrintf("velocity = %d (%d, %d)\n", vel, tmp_buffer[0], tmp_buffer[1]);
            break;
        case 'm':
            if (mxGetNumberOfElements(ptr) < 3) {
                mexPrintf("Command v requires 3 values in double\n");
                return (-1);
            }
            //Should do error handling!!
            xyz = mxGetPr(ptr);
            for (i=0; i<3; i++) {
                for (j=3; j>0; j--) {
                    k = (int)(floor((xyz[i] / pow(256, j))));
                    xyz[i] = (int)xyz[i] % (int)pow(256, j);
                    tmp_buffer[i*4+j] = (unsigned int)k;
                }
                tmp_buffer[i*4] = (unsigned int)xyz[i];
            }
//             for (i=0; i < 12; i++) mexPrintf("%d-", tmp_buffer[i]);
//             mexPrintf("\n");
            break;       
    }
    return (0);
}


void setup_parameters(char *bytes_to_send, int *command_mode, 
        int *inputSize, int *readSize, bool *needReturnCR, bool *CRafterCommand){
    
        switch (bytes_to_send[0]){
        case 'v':
            //mexPrintf("Set velocity to ");
            *command_mode = serial_WRITE;
            *inputSize = 2;
            *needReturnCR = true;        
            break;
        case 'm':
            //mexPrintf("Set position to ");
            *command_mode = serial_WRITE;
            *inputSize = 12;
            *needReturnCR = true;
            break;
        case 's':
            //mexPrintf("Get status\n");
            *command_mode = serial_READ;
            *readSize = 32;
            break;
        case 'c':
            //mexPrintf("Get position\n");
            *command_mode = serial_READ;
            *readSize = 12;
            break;
        case 'f':
            //mexPrintf("Reading\n");
            *command_mode = serial_READ_only;
            *inputSize = 1;
            *needReturnCR = true;
            break;
        case 'n':
            //mexPrintf("Refresh\n");
            *command_mode = serial_COMMAND_only;
            *CRafterCommand = true;
            *needReturnCR = true;
            break;
        case 'r':
            //mexPrintf("Reset\n");
            *command_mode = serial_COMMAND_only;
            *CRafterCommand = true;
            *needReturnCR = false;
            break;
        case 'o':
            *command_mode = serial_COMMAND_only;
            *needReturnCR = true;
            break;
        case 3:
            //mexPrintf("SetOrigin\n");
            *command_mode = serial_COMMAND_only;
            *needReturnCR = true;
            *CRafterCommand = false;
            break;
        default:
            mexPrintf("Command error ? %s (%d) \n", bytes_to_send, bytes_to_send[0]);
            *command_mode = serial_COMMAND_only;
            *needReturnCR = true;
            *CRafterCommand = true;
            break;
     }
}

/////////////////////////////////////////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////// 

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
///////////////////////////////////////////////////////////////////////////     
    
    unsigned char bytes_to_send[1];  //Command to send
    unsigned char commandChar[2];
    unsigned char tmp_buffer[64];    //Values to send and receive
    unsigned char ComName[8];
    double output_buffer[64];
    
    //int charN;
    int i, j, k;
    double val; // temporary storage
    int baudRate=9600;
    int inputSize = 1;
    int outputSize = 1;
    int readSize = 0; //Only return.
    int errorCode = 0; 
    int valueInputID; 
    double timeout = 5;
    double *xyz;
    
    mwSize buflen;
    
    int command_mode = serial_COMMAND_only;

    bool needReturnCR = false;
    bool CRafterCommand = true;
    HANDLE hSerial;
    
///////////////////////////////////////////////////////////////////////////  
    
    if (nrhs < 4){
            mexPrintf("Needs > 4 inputs.\n");
            errorCode = -1;
    } else {
        //Reading 1st input
        if (mxGetClassID(prhs[0]) == mxCHAR_CLASS) {
            buflen = mxGetNumberOfElements(prhs[0]) + 1;
            mxGetString(prhs[0], ComName, buflen);
        } else {
            mexPrintf("Port name must be string char.\n");
            errorCode = -1;
        }

        //Reading 2nd input
        if (mxGetClassID(prhs[1]) == mxDOUBLE_CLASS)
            baudRate = (int)mxGetScalar(prhs[1]);
        else {
            mexPrintf("Baud rate must be in Double.\n");
            errorCode = -1;
        }

        //Reading 3rd input    
        if (mxGetClassID(prhs[2]) == mxDOUBLE_CLASS)
            timeout = mxGetScalar(prhs[2]);
        else {
            mexPrintf("Timeout must be in Double.\n");
            errorCode = -1;
        }

        //Reading 4th input     
        if (mxGetClassID(prhs[3]) == mxCHAR_CLASS){
            buflen = mxGetNumberOfElements(prhs[3]) + 1;
            mxGetString(prhs[3], commandChar, buflen);
        } else {
            mexPrintf("Port name must be a char.\n");
            errorCode = -1;
        }

        // for v and m command prhs[4] or 5th value is the input value.
        valueInputID = 4;  
        
        bytes_to_send[0] = commandChar[0];    
        setup_parameters(bytes_to_send, &command_mode, &inputSize, 
                &readSize, &needReturnCR, &CRafterCommand);

        //Reading 5th input if necessary.
        if ( (bytes_to_send[0] == 'v') | (bytes_to_send[0] == 'm') )
            errorCode = reading_input_value(bytes_to_send, 
                    prhs[valueInputID], nrhs, valueInputID, &tmp_buffer);
        
    }
    
/////////////////////////////////////////////////////////////////////////// 
//Open serial port    
    //mexPrintf("Opening serial port %s ...\n", ComName);
    
    Sleep(350);
    
    if (errorCode == 0)
        errorCode = open_serial_port (&hSerial, ComName, baudRate);           

    Sleep(10);   
    
   // mexPrintf("Sending command...\n");
    if (errorCode == 0)
        errorCode = send_serial_command_all (hSerial, bytes_to_send,
                command_mode, CRafterCommand, tmp_buffer, inputSize);
        

    Sleep(10);   

    //mexPrintf("errorCode, %d\n", errorCode);
   // mexPrintf("Reading values...\n");
    if (errorCode == 0)
        errorCode = receive_analyze_serial_data (hSerial, tmp_buffer, 
                readSize, timeout, command_mode, needReturnCR, commandChar, 
                &outputSize, &output_buffer);
        

    if (CloseHandle(hSerial) == 0){
        //mexPrintf("Error while closing serial\n");
    }
    
    Sleep(10);
    
    if (errorCode < 0) {
        outputSize = 1; //just to make sure
        output_buffer[0] = (double) errorCode;
    }
    
    plhs[0] = mxCreateDoubleMatrix(1,outputSize, mxREAL);
    xyz = mxGetPr(plhs[0]);
    for (i=0; i<outputSize; i++)
            xyz[i] = output_buffer[i];


}
