#ifndef Array_H
#define Array_H

/*
 ============================================================================
 Author: kewenya

	注意 Array使用，定义后需进行初始化ArrayInit，使用后需释放资源Reset
	例如:
	Array text;
	ArrayInit( &text );
	text.Reset( &text );
 ============================================================================
*/


#include <stdio.h>
#include <stdlib.h>

//最大空间为   MALLOC_SIZE*INDEX_NUM_MAX = 12800

#define MALLOC_NUM  8   //2进制  个数为1<<MALLOC_NUM
#define MALLOC_SIZE 256 // = 1<<MALLOC_NUM
#define INDEX_NUM_MAX  50



#define MallocIndexByte (INDEX_NUM_MAX*sizeof(int))
#define MallocByte (MALLOC_SIZE*sizeof(int))

typedef struct ArrayData
{
	uintptr_t* pData;
	struct ArrayData* next;
}ArrayData;

typedef struct Array
{	
	int size;
	int mallocsize;       //数据域个数

	uintptr_t** pIndexData;	  //索引空间首地址
	int pIndexNum;        //索引空间个数

	uintptr_t* pDataEnd;

	void (*Append)(struct Array* A,uintptr_t value);
	void (*Insert)(struct Array* A,uintptr_t value,int pos);
	void (*Remove)(struct Array* A,int index);
	void (*Reset)(struct Array* A);
	uintptr_t (*GetValue)(struct Array* A,int index);

}Array;

void ArrayInit(struct Array* A);
void ArrayAppend(Array* A,uintptr_t value);
void ArrayInsert(Array* A,uintptr_t value,int pos);
void ArrayRemove(Array* A,int index);
void ArrayReset(Array* A);
int ArrayReSize(Array* A);
uintptr_t ArrayGetValue(Array* A,int index);


typedef struct ArrayC
{	
	int  size;			
	int  pDataSize;       //数据域个数
	uintptr_t *pData;         //空间首地址
	
	uintptr_t* pDataEnd;

	void (*Append)(struct ArrayC* A,uintptr_t value);
	void (*Reset)(struct ArrayC* A);
	void (*SetSize)(struct ArrayC* A,int size);
	uintptr_t (*GetValue)(struct ArrayC* A,int index);

}ArrayC;


void ArrayCInit(struct ArrayC* A);
void ArrayCAppend(ArrayC* A,uintptr_t value);
void ArrayCReset(ArrayC* A);
uintptr_t  ArrayCGetValue(ArrayC* A,int index);
void ArrayCSetSize(struct ArrayC* A,int size);

#endif
