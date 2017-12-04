// test_FrameQueue.cpp : Defines the entry point for the console application.
//

#include <tchar.h>
#include "stdio.h"
#include "FrameQueue.h"

int _tmain(int argc, _TCHAR* argv[])
{
	FrameQueue *fq = new FrameQueue();	
	fq->init(3,5,2);

	std::string str = "ab";
	fq->push_front(str.c_str());
	str = "cd";
	fq->push_front(str.c_str());

	printf("tnpf: %d, ndpf: %d, size: %d\n",fq->total_num_push_front(),fq->num_dropped_push_front(),fq->size());
	std::string tmp(static_cast<const char *>(fq->front()));
	printf("front: %s\n",tmp.c_str());
	fq->pop_front();
	tmp = static_cast<const char*>(fq->front());
	printf("front: %s\n",tmp.c_str());
	fq->pop_front();

	str = "11";
	fq->push_front(str.c_str());
	str = "22";
	fq->push_front(str.c_str());
	str = "33";
	fq->push_front(str.c_str());
	str = "44";
	fq->push_front(str.c_str());
	str = "55";
	fq->push_front(str.c_str());
	str = "66";
	fq->push_front(str.c_str());

	const std::vector<unsigned long> &dropped = fq->dropped_push_front();
	printf("tnpf: %d, ndpf: %d, size: %d, first dropped: %d\n",
			fq->total_num_push_front(),fq->num_dropped_push_front(),fq->size(),dropped[0]);
	tmp = static_cast<const char*>(fq->front());
	printf("front: %s\n",tmp.c_str());
	fq->pop_front();	
	
	str = "77";
	fq->push_front(str.c_str());
	str = "88";
	fq->push_front(str.c_str());

	const std::vector<unsigned long> &dropped2 = fq->dropped_push_front();
	printf("tnpf: %d, ndpf: %d, size: %d, first dropped 1, 2: %d, %d\n",
			fq->total_num_push_front(),fq->num_dropped_push_front(),fq->size(),dropped2[0],dropped2[1]);
	tmp = static_cast<const char*>(fq->front());
	printf("front: %s\n",tmp.c_str());
	fq->pop_front();	

	return 0;
}

