//----------------------------------------------------
// Copyright (c) 2014, SHENZHEN PENGRUI SOFT CO LTD. All rights reserved.

// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------------------
// Copyright (c) 2014 ����Ȩ�����������������޹�˾���С�����Ȩ�˱���һ��Ȩ����
// 
// �����Ȩ�����ʹ���߷������������������£�����ʹ����ʹ�ü���ɢ����
// ������װԭʼ�뼰����λ��ִ����ʽ��Ȩ�������۴˰�װ�Ƿ񾭸�����Ȼ��
// 
// 1. ���ڱ�����Դ�������ɢ�������뱣�������İ�Ȩ���桢�������б�����
//    ������������������
// 2. ���ڱ��׼�����λ��ִ����ʽ����ɢ���������������ļ��Լ�������������
//    ��ɢ����װ�е�ý�鷽ʽ����������֮��Ȩ���桢�������б����Լ�����
//    ������������

// �����������������Ǳ�������Ȩ�������Լ�����������״��"as is"���ṩ��
// ��������װ�����κ���ʾ��Ĭʾ֮�������Σ������������ھ��������Լ��ض�Ŀ
// �ĵ�������ΪĬʾ�Ե�������Ȩ�����˼�������֮�����ߣ������κ�������
// ���۳�����κ��������塢���۴�����Ϊ���Լ��ϵ���޹�ʧ������������Υ
// Լ֮��Ȩ��������ʧ������ԭ��ȣ����𣬶����κ���ʹ�ñ�������װ��������
// �κ�ֱ���ԡ�����ԡ�ż���ԡ������ԡ��ͷ��Ի��κν�����𺦣�����������
// �������Ʒ������֮���á�ʹ����ʧ��������ʧ��������ʧ��ҵ���жϵȵȣ���
// �����κ����Σ����ڸ���ʹ���ѻ���ǰ��֪���ܻ���ɴ����𺦵���������Ȼ��
//-----------------------------------------------------------------------------
/*
@����ģ��:������
@���ߣ�lst
@�汾��V1.0.0
@�ļ�����:����������CPUֱ����صĻ�����,��Ҫ���쳣�����߳��л���
@����˵��:
@�޶���ʷ:
@2. ...
@1. ����: 2009-01-04
@   ����: lst
@   �°汾��: V1.0.0
@   �޸�˵��: ԭʼ�汾
@------------------------------------------------------
@ ע: psp����������ջ�У�������vm->stack��!!
*/


.file   "cpus.S";

//#include "cpu_peri_int_line.h"
//#include "cpu_peri_address.h"
#include "def21469.h"
#include "lib_glob.h"
#include "sig_glob.h"

.extern  ___Djy_VmEngine;
.extern  _Int_ContactAsynSignal;
.extern  _Int_HalfEnableAsynSignal;

.extern ___backup_all_regs;
.extern ___restore_all_regs;


/*
@----�����ں�ʱ�ӵ�ǰTCOUNTֵ�����ֵ֮��-------------------------------------------------------------------
@����:  �����ں�ʱ�ӵ�ǰTCOUNTֵ�����ֵ֮��
@����:  ��
@����:  ��ǰTCOUNT��TPERIOD����ֵ��ֵ
@����ԭ��:u32 _asm_get_tick()
@-------------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global _asm_get_tick;
.extern _core_time;
_asm_get_tick:
  r1=TPERIOD;
  r2=TCOUNT;
  r0=r1-r2;
  FETCH_RETURN
      RETURN (DB);
      rframe;
      nop;
  _asm_get_tick.end:




/*
@----�����߳�-------------------------------------------------------------------
@����:  ��ʼ���̵߳�ջ���������߳�ִ�к������´����߳�ʱ������ñ�����
@����:  thread_routine�������õ��̺߳���
@       vm���߳�ָ��
@����:  ��ʼ��������ĵ�ǰջָ��
@����ԭ��:void * __asm_reset_thread(void (*thread_routine)(struct event_script *),
@                                        struct  tagThreadVm  *vm)@
@-------------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_reset_thread;
___asm_reset_thread:
   //���Ƚ�����ຯ��ʹ�õ��ļĴ�����ջ����
    modify(I7,-2);
    R1=I2; 
    DM(1,I7)=R1;
    R1=I13;
    DM(0,I7)=R1;
    I4=R8;     //����ADSP21469�������ݹ���R8=stack                     	
    R2=DM(M6,I4);I2=R2;		//ȡ�����ջ��ָ��  ����������ṹ���ڶ���Ԫ��Ϊ�洢ջ��ָ��
    //ȡ�������ջ��ָ��󣬼������߳�ջ�ṹ���ζ�ջ�и���λ�ó�ʼ��
    R2=___Djy_VmEngine;	//ȡ���������ָ��
    modify(I2,-130);			//������ջ�ռ�
    DM(130,I2)=R2;          //_djy_vm_engine�����ΪPC��ַ����PC��ַ��������ջ���߳�ջ��һ��λ�ô洢PC
   // save r1, r2, i2, i13 at first
    DM(129,I2)=R1;
    DM(128,I2)=R2;
    R1=I2;
    DM(127,I2)=R1;
    DM(126,I2)=I13;
    R1=I6; 
    DM(125,I2)=R1;
  // Save STKYx USTAT1-4
   MODE2=0x42000027;
   nop;
   nop;
   R1=MODE2;
   DM(123,I2)=R1;
   STKYx=0x05400000;     //�������ϵ��MODE2��STKYx��Ĭ��ֵ
   nop;
   nop;
    R1=STKYx; 
    DM(122,I2)=R1;
    STKYy=0x5400000;
    nop;
    nop;
    R1=STKYy;
    DM(121,I2)=R1;
    R1 = USTAT1; 
    DM(120,I2)=R1;
    R1 = USTAT2; 
    DM(119,I2)=R1;
    R1 = USTAT3; 
    DM(118,I2)=R1;
    R1 = USTAT4; 
    DM(117,I2)=R1;
    
       // Save and zero all the relevant L registers
        R1=L0; DM(116,I2)=R1;
        R1=L1; DM(115,I2)=R1;
        R1=L2; DM(114,I2)=R1;
        R1=L3; DM(113,I2)=R1;
        R1=L5; DM(112,I2)=R1;
        
        DM(111,I2)=L8;
        DM(110,I2)=L9;
        DM(109,I2)=L10;
        DM(108,I2)=L11;
        DM(107,I2)=L13;
        DM(106,I2)=L14;
        DM(105,I2)=L15;
      
        L0=0;
        L1=0;
        L2=0;
        L3=0;
        // L4 saved below
        L5=0;
        L8=0;
        L9=0;
        L10=0;
        L11=0;
        // L12 saved below
        L13=0;
        L14=0;
        L15=0;
        
       // Save PX registers
       DM(104,I2)=PX1;
       DM(103,I2)=PX2;
// All 40 bits of these registers must be saved. They are used in
// the integer divide routine and loss of accuracy in these registers
// will result in the wrong answer being generated.
        PX=R0; DM(102,I2)=PX1;DM(101,I2)=PX2;
        PX=R3; DM(100,I2)=PX1;DM(99,I2)=PX2;
        PX=R4; DM(98,I2)=PX1;DM(97,I2)=PX2;
        PX=R7; DM(96,I2)=PX1;DM(95,I2)=PX2;
        PX=R8; DM(94,I2)=PX1;DM(93,I2)=PX2;
        PX=R9; DM(92,I2)=PX1;DM(91,I2)=PX2;
        PX=R11;DM(90,I2)=PX1;DM(89,I2)=PX2;
        PX=R12;DM(88,I2)=PX1;DM(87,I2)=PX2;
		// R1\R2 saved below        
       DM(86,I2)=R5;
       DM(85,I2)=R6;
	   DM(84,I2)=R10;
       DM(83,I2)=R13;
       DM(82,I2)=R14;
       DM(81,I2)=R15;	 
// Save all of the Sregs. We can't do these saves and restores in
// SIMD mode in case the stack is in external memory.
// Note that on 2116x and above, we no longer save MODE1 and ASTAT
// - they are saved by the 'push sts' instruction in the vector table.
        PX=S0; DM(80,I2)=PX1;DM(79,I2)=PX2;
        PX=S4; DM(78,I2)=PX1;DM(77,I2)=PX2;
        PX=S9; DM(76,I2)=PX1;DM(75,I2)=PX2;
        PX=S11;DM(74,I2)=PX1;DM(73,I2)=PX2;
        PX=S12;DM(72,I2)=PX1;DM(71,I2)=PX2;
        
        DM(70,I2)=S1;
        DM(69,I2)=S2;
        DM(68,I2)=S3;
        DM(67,I2)=S5;
        DM(66,I2)=S6;
        DM(65,I2)=S7;
        DM(64,I2)=S8;
        DM(63,I2)=S10;
        DM(62,I2)=S13;
        DM(61,I2)=S14;
        DM(60,I2)=S15;
        
        BIT SET MODE1 RND32;
        nop;nop;

// Save the relevant DAG1 M registers - M0-3. M4 is saved later, M5-7 are
// constant.
        R1=M0;
        DM(59,I2)=R1;
        R1=M1;
        DM(58,I2)=R1;
        R1=M2;
        DM(57,I2)=R1;
        R1=M3;
        DM(56,I2)=R1;
       
// Save the relevant DAG2 M registers - M8-11. M12 is saved later, M13-15
// are constant.
        DM(55,I2)=M8;
        DM(54,I2)=M9;
        DM(53,I2)=M10;
        DM(52,I2)=M11;

// Save the Iregs
        R1=I0;
        DM(51,I2)=R1;
        R1=I1;
        DM(50,I2)=R1;
        R1=I3;
        DM(49,I2)=R1;
        R1=I5;
        DM(48,I2)=R1;
        
        DM(47,I2)=I8;
        DM(46,I2)=I9;
        DM(45,I2)=I10;
        DM(44,I2)=I11;
        DM(43,I2)=I14;
        DM(42,I2)=I15; 
       
// Save the scratch DAG registers on the stack.
        DM(41,I2)=pm_ptr;   // save i12
        DM(40,I2)=pm_bse;   // save b12
        DM(39,I2)=pm_mdf;   // save m12
        DM(38,I2)=pm_lnt;   // save l12

        R0=dm_ptr;
        DM(37,I2)=R0;        // save i4
        R0=dm_bse;
        DM(36,I2)=R0;        // save b4
        R0=dm_mdf; 
        DM(35,I2)=R0;        // save m4
        R0=dm_lnt;
        DM(34,I2)=R0;        // save l4
            
        //save B registers
        R1=B0;   DM(33,I2)=R0;   
        R1=B1;   DM(32,I2)=R0;   
        R1=B2;   DM(31,I2)=R0;   
        R1=B3;   DM(30,I2)=R0;   
        R1=B5;   DM(29,I2)=R0;   
        
        DM(28,I2)=B8; 
        DM(27,I2)=B9; 
        DM(26,I2)=B10;
        DM(25,I2)=B11;
        DM(24,I2)=B13;
        DM(23,I2)=B14;
        DM(22,I2)=B15;
            
      
 // ������������ͨ�üĴ�������λ��ϣ���������Ӳ��ջ��ASTAT�Ĵ�����λ���ϵ�״̬
       
 		//��ʼ��PC STACK���߳�ջ��ֵ
        R2=0;
        DM(9,I2)=R2;   //PC stack��ʱΪ��
 		//��ʼ��STATUS STACK���߳�ջ��ֵ
        R1=MODE1;      
        R2=0x00001000;  //ȫ���ж�ʹ��λ��0
        R2=NOT R2;
        R2=R1 and R2;
	R1=0x00000800;  //�ж�Ƕ��ʹ��λ��1
	R2=R1 or R2;
        R1=0x04fc;		//����ڶ��׼Ĵ�����ʹ�ܵģ�����BUG
        R1=NOT R1;
        R2=R1 and R2;
        DM(8,I2)=R2;
        ASTATx=0x0;
        nop;
        nop;
        R2=ASTATx;
        DM(7,I2)=R2;
        ASTATy=0x0;
        nop;
        nop;
        R2=ASTATy;
        DM(6,I2)=R2;
        R2=1;
        DM(5,I2)=R2;   //status stack ��ʱѹ���ʼ��ֵ����status number��1
        //��ʼ��LOOP STACK���߳�ջ��ֵ
        R2 = 0x00000001;
        DM(4,I2)=R2;    //LCNTR
        R2 = 0xFFFFFFFF;
        DM(3,I2)=R2;   //Loop Address  LADDR
        R2 = 0xFFFFFFFF;
        DM(2,I2)=R2;   //Loop Counter  CURLCNTR
        R2=1;
        DM(1,I2)=R2;   //loop stack ��ʱѹ���ʼ��ֵ����status number��1
       
       I4=R8;
       R2=I2;
       DM(I4,M5)=R2;   //��i7��ǰ��λ��Ҳ��vm�ĵ�ǰָ�뱣�浽R8���ڵĵ�ַ����Ҳ��vm��ջ�ױ�����
    
    //�ָ����뱾������ѹջ�ļĴ���
    R1=DM(0,I7);  I13=R1;
    R1=DM(1,I7); I2=R1;    
    alter(2);  
      FETCH_RETURN
      RETURN (DB);
      rframe;
      nop;
.___asm_reset_thread.end:
/*
@----��λ���̣߳��л������߳�-------------------------------------------------
@����:  ��old_vm�����������³�ʼ�����´�����״̬��Ȼ���л������̵߳�
@       �������м���ִ�С�
@       ��һ���ڳ�פ�ڴ���߳��д������¼���ɺ󣬲���ɾ�����̣߳����븴λ
@       ���̣߳�Ȼ���л������������̣߳���ʱ�����Ҫ���ñ���������˱�������
@       ����λ���߳�����������ִ�С�
@����:  thread_routine�������õ��̺߳���
@       new_vm��Ŀ���̵߳��߳�
@       old_vm������λ���߳�
@����:  ��
@����ԭ��:void __asm_reset_switch(void (*thread_routine)(void),
@                           struct  tagThreadVm *new_vm,struct  tagThreadVm *old_vm)@
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_reset_switch;
___asm_reset_switch:

    bit clr MODE1 0x1000;		// Disable int
       I4=R12;                   //����ADSP21469�������ݹ���R12=old_vm
       R2=DM(M6,I4);             //ȡ�������ջ��ָ��
       I7=R2;
       R2=___Djy_VmEngine;

    modify(I7,-130);			//������ջ�ռ�
    DM(130,I7)=R2;          //_djy_vm_engine�����ΪPC��ַ����PC��ַ��������ջ���߳�ջ��һ��λ�ô洢PC
    
   // save r1, r2, i2, i13 at first
    DM(129,I7)=R1;
    DM(128,I7)=R2;
    R1=I2;
    DM(127,I7)=R1;
    DM(126,I7)=I13;
    R1=I6; 
    DM(125,I7)=R1;
  // Save STKYx USTAT1-4
   MODE2=0x42000027;
   nop;
   nop;
   R1=MODE2;
   DM(123,I7)=R1;
   STKYx=0x05400000;     //�������ϵ��MODE2��STKYx��Ĭ��ֵ
   nop;
   nop;
    R1=STKYx; 
    DM(122,I7)=R1;
    STKYy=0x5400000;
    nop;
    nop;
    R1=STKYy;
    DM(121,I7)=R1;
    R1 = USTAT1; 
    DM(122,I7)=R1;
    R1 = USTAT2; 
    DM(120,I7)=R1;
    R1 = USTAT3; 
    DM(118,I7)=R1;
    R1 = USTAT4; 
    DM(117,I7)=R1;
    
       // Save and zero all the relevant L registers
        R1=L0; DM(116,I7)=R1;
        R1=L1; DM(115,I7)=R1;
        R1=L2; DM(114,I7)=R1;
        R1=L3; DM(113,I7)=R1;
        R1=L5; DM(112,I7)=R1;
        DM(111,I7)=L8;
        DM(110,I7)=L9;
        DM(109,I7)=L10;
        DM(108,I7)=L11;
        DM(107,I7)=L13;
        DM(106,I7)=L14;
        DM(105,I7)=L15;
        L0=0;
        L1=0;
        L2=0;
        L3=0;
        // L4 saved below
        L5=0;
        L8=0;
        L9=0;
        L10=0;
        L11=0;
        // L12 saved below
        L13=0;
        L14=0;
        L15=0;
        
       // Save PX registers
       DM(104,I7)=PX1;
       DM(103,I7)=PX2;
// All 40 bits of these registers must be saved. They are used in
// the integer divide routine and loss of accuracy in these registers
// will result in the wrong answer being generated.
        PX=R0; DM(102,I7)=PX1;DM(101,I7)=PX2;
        PX=R3; DM(100,I7)=PX1;DM(99,I7)=PX2;
        PX=R4; DM(98,I7)=PX1;DM(97,I7)=PX2;
        PX=R7; DM(96,I7)=PX1;DM(95,I7)=PX2;
        PX=R8; DM(94,I7)=PX1;DM(93,I7)=PX2;
        PX=R9; DM(92,I7)=PX1;DM(91,I7)=PX2;
        PX=R11;DM(90,I7)=PX1;DM(89,I7)=PX2;
        PX=R12;DM(88,I7)=PX1;DM(87,I7)=PX2;
		// R1\R2 saved below        
       DM(86,I7)=R5;
       DM(85,I7)=R6;
	   DM(84,I7)=R10;
       DM(83,I7)=R13;
       DM(82,I7)=R14;
       DM(81,I7)=R15;	 
// Save all of the Sregs. We can't do these saves and restores in
// SIMD mode in case the stack is in external memory.
// Note that on 2116x and above, we no longer save MODE1 and ASTAT
// - they are saved by the 'push sts' instruction in the vector table.
        PX=S0; DM(80,I7)=PX1;DM(79,I7)=PX2;
        PX=S4; DM(78,I7)=PX1;DM(77,I7)=PX2;
        PX=S9; DM(76,I7)=PX1;DM(75,I7)=PX2;
        PX=S11;DM(74,I7)=PX1;DM(73,I7)=PX2;
        PX=S12;DM(72,I7)=PX1;DM(71,I7)=PX2;
        
        DM(70,I7)=S1;
        DM(69,I7)=S2;
        DM(68,I7)=S3;
        DM(67,I7)=S5;
        DM(66,I7)=S6;
        DM(65,I7)=S7;
        DM(64,I7)=S8;
        DM(63,I7)=S10;
        DM(62,I7)=S13;
        DM(61,I7)=S14;
        DM(60,I7)=S15;
        
        BIT SET MODE1 RND32;
        nop;nop;

// Save the relevant DAG1 M registers - M0-3. M4 is saved later, M5-7 are
// constant.
        R1=M0;
        DM(59,I7)=R1;
        R1=M1;
        DM(58,I7)=R1;
        R1=M2;
        DM(57,I7)=R1;
        R1=M3;
        DM(56,I7)=R1;
       
// Save the relevant DAG2 M registers - M8-11. M12 is saved later, M13-15
// are constant.
        DM(55,I7)=M8;
        DM(54,I7)=M9;
        DM(53,I7)=M10;
        DM(52,I7)=M11;

// Save the Iregs
        R1=I0;
        DM(51,I7)=R1;
        R1=I1;
        DM(50,I7)=R1;
        R1=I3;
        DM(49,I7)=R1;
        R1=I5;
        DM(48,I7)=R1;
        
        DM(47,I7)=I8;
        DM(46,I7)=I9;
        DM(45,I7)=I10;
        DM(44,I7)=I11;
        DM(43,I7)=I14;
        DM(42,I7)=I15; 
       
// Save the scratch DAG registers on the stack.
        DM(41,I7)=pm_ptr;   // save i12
        DM(40,I7)=pm_bse;   // save b12
        DM(39,I7)=pm_mdf;   // save m12
        DM(38,I7)=pm_lnt;   // save l12

        R0=dm_ptr;
        DM(37,I7)=R0;        // save i4
        R0=dm_bse;
        DM(36,I7)=R0;        // save b4
        R0=dm_mdf; 
        DM(35,I7)=R0;        // save m4
        R0=dm_lnt;
        DM(34,I7)=R0;        // save l4
            
        //save B registers
        R1=B0;   DM(33,I7)=R0;   
        R1=B1;   DM(32,I7)=R0;   
        R1=B2;   DM(31,I7)=R0;   
        R1=B3;   DM(30,I7)=R0;   
        R1=B5;   DM(29,I7)=R0;   
        
        DM(28,I7)=B8; 
        DM(27,I7)=B9; 
        DM(26,I7)=B10;
        DM(25,I7)=B11;
        DM(24,I7)=B13;
        DM(23,I7)=B14;
        DM(22,I7)=B15;
            
      
 // ������������ͨ�üĴ�������λ��ϣ���������Ӳ��ջ��ASTAT�Ĵ�����λ���ϵ�״̬
       
 		//��ʼ��PC STACK���߳�ջ��ֵ
        R2=0;
        DM(9,I7)=R2;   //PC stack��ʱΪ��
 		//��ʼ��STATUS STACK���߳�ջ��ֵ
        R1=MODE1;      
        R2=0x00001000;  //ȫ���ж�ʹ��λ��0
        R2=NOT R2;
        R2=R1 and R2;
	R1=0x00000800;  //�ж�Ƕ��ʹ��λ��1
	R2=R1 or R2;
        R1=0x04fc;		//����ڶ��׼Ĵ�����ʹ�ܵģ�����BUG
        R1=NOT R1;
        R2=R1 and R2;
        DM(8,I7)=R2;
        ASTATx=0x0;
        nop;
        nop;
        R2=ASTATx;
        DM(7,I7)=R2;
        ASTATy=0x0;
        nop;
        nop;
        R2=ASTATy;
        DM(6,I7)=R2;
        R2=1;
        DM(5,I7)=R2;   //status stack ��ʱѹ���ʼ��ֵ����status number��1
        //��ʼ��LOOP STACK���߳�ջ��ֵ
        R2 = 0x00000001;
        DM(4,I7)=R2;    //LCNTR
        R2 = 0xFFFFFFFF;
        DM(3,I7)=R2;   //Loop Address  LADDR
        R2 = 0xFFFFFFFF;
        DM(2,I7)=R2;   //Loop Counter  CURLCNTR
        R2=1;
        DM(1,I7)=R2;   //loop stack ��ʱѹ���ʼ��ֵ����status number��1

        //���˾��̸߳�λ���    
       I4=R12;
       R2=I7;
       DM(I4,M5)=R2;          //��I7��ǰ��λ��Ҳ��vm�ĵ�ǰָ�뱣�浽R12���ڵĵ�ַ����Ҳ��vm��ջ�ױ����� 

      //��ʼ�л����̣߳������߳������Ļָ�
       I4=R8;                  //R8���� new vm�ṹ���׵�ַ��Ҳ��new vm->stack
       I12=I4;        
       R2=DM(M6,I4);     //ȡ�����ջ��ָ��  ����������ṹ���ڶ���Ԫ��Ϊ�洢ջ��ָ��
    //������Ҫȡvm�ṹ����stack_size������� vm->stack_size�����Ա��vm�ṹ���е�4��λ��
      R0=I4;
      R1=2;
      R0=R1+R0;
      I4=R0;
      R1=DM(M6,I4); //ȡ��vm->stack_sizeֵ����������vm->stack_sizeֵ����L7��ͬʱ����ջ����ջ��L7���ջ�ײ���ֵ��B7
      L7=R1;
      R0=R2-R1;
      R0=R0+1;
      B7=R0;
      I4=I12;
      R2=DM(M5,I4);
      I7=R2;
      B6=B7;		//һ����Ҫ������
      L6=L7;
       
    //��ʼ����C����int_half_enable_asyn_signal,�ڵ���C����֮ǰ���������Ԥ������
      R2=I6;
      I6=I7;
     I12=_Int_HalfEnableAsynSignal;
     JUMP(M13,I12)(DB);
     DM(I7,M7)=R2;
     DM(I7,M7)=PC;
 //���Ȼָ�Ӳ��ջ������,��ʼ��Ӳ��ջ	
	R0=DM(1,I7);
	modify(I7,1);					//ȡR0������LOOPջ����
	R0 = R0 - 1;
	IF EQ JUMP (.restore_loop_end_reset_switch);			//if R0==0,jump
.restore_loop_start_reset_switch:
    R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);
	push loop;
	R0 = R0 - 1;
	IF NE JUMP (.restore_loop_start_reset_switch);
.restore_loop_end_reset_switch:
    R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);        //loop��ջ������status��ջ��ʼ
	R0=DM(1,I7);         //ȡR0������STATUSջ����
	modify(I7,1); 				
	R0 = R0 - 1;
	IF EQ JUMP (.restore_sts_end_reset_switch);			//if R0==0,jump
.restore_sts_start_reset_switch:
///	R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
    R2=DM(3,I7);  MODE1 = R2;
    nop;nop;
    modify(I7,3); 	
	push sts;
	R0 = R0 - 1;
	IF NE JUMP (.restore_sts_start_reset_switch);
.restore_sts_end_reset_switch:
///	R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
    R2=DM(3,I7);  MODE1 = R2;
    nop;nop;
    modify(I7,3); 	
	//status��ջ������pc��ջ��ʼ
	R0=DM(1,I7);  //ȡR0������PCջ����
	modify(I7,1); 				
	R0 = PASS R0;
	IF EQ JUMP (.restore_pc_end_reset_switch);			//if R0==0,jump
.restore_pc_start_reset_switch:
	push pcstk;
	R2=DM(1,I7); PCSTK = R2;
    modify(I7,1); 
	R0 = R0 - 1;
	IF NE JUMP (.restore_pc_start_reset_switch);
.restore_pc_end_reset_switch:
	nop;
//���ˣ���Ӳ��ջ����,���濪ʼ�ָ��Ĵ���ֵ
    call ___restore_all_regs;  //ͨ�üĴ�����ջ
    I12=DM(1,I7);
    modify(I7,1); 
    JUMP(M13,I12)(db);
     nop;
     bit set MODE1 0x1000;		// Enable int
.___asm_reset_switch.end:

/*
@----�������¼�����-----------------------------------------------------------
@����: ϵͳ��ʼ����ɺ��������¼����Ȳ������һ���¼�.
@����: new_vm���״��������߳̿��ƿ�ָ��
@����: ��
@����ԭ��: void __asm_start_thread(struct  tagThreadVm  *new_vm)@
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global __asm_start_thread;
__asm_start_thread:
    nop;
.__asm_start_thread.end:

/*
@----����������---------------------------------------------------------------
@����:  ������ԭ�����ģ�ֱ�������µ�������ִ��
@����:  new_vm����������߳̿��ƿ�ָ��
@����:  ��
@����ԭ��: void __asm_turnto_context(struct  tagThreadVm  *new_vm)@
@˵��:  ���¼����,��û�б�Ҫ������¼���������,ֱ���л������¼�����.
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_turnto_context;
___asm_turnto_context:

    bit clr MODE1 0x1000;		// Disable int
    
    I4=R4;            //R4���� new vm�ṹ���׵�ַ��Ҳ��new vm->stack
    I12=I4;        
    R2=DM(M6,I4);     //ȡ�����ջ��ָ��  ����������ṹ���ڶ���Ԫ��Ϊ�洢ջ��ָ��
    //������Ҫȡvm�ṹ����stack_size������� vm->stack_size�����Ա��vm�ṹ���е�4��λ��
    R0=I4;
    R1=2;
    R0=R1+R0;
    I4=R0;
    R1=DM(M6,I4); //ȡ��vm->stack_sizeֵ����������vm->stack_sizeֵ����L7��ͬʱ����ջ����ջ��L7���ջ�ײ���ֵ��B7
    L7=R1;
    R0=R2-R1;
    R0=R0+1;
    B7=R0;
    I4=I12;
    R2=DM(M5,I4);
    I7=R2;
      B6=B7;		//һ����Ҫ������
      L6=L7;
    //��ʼ����C����int_half_enable_asyn_signal,�ڵ���C����֮ǰ���������Ԥ������
    R2=I6;
    I6=I7;
    I12=_Int_HalfEnableAsynSignal;
    JUMP(M13,I12)(DB);
     DM(I7,M7)=R2;
     DM(I7,M7)=PC;
   //���Ȼָ�Ӳ��ջ������,��ʼ��Ӳ��ջ��ע�⣬��ʱ��Ӳ��ջ���Ѿ�Ϊ����	
	R0=DM(1,I7);
	modify(I7,1);					//ȡR0������LOOPջ����
	R0 = R0 - 1;
	IF EQ JUMP (.restore_loop_end_turnto);			//if R0==0,jump
.restore_loop_start_turnto:
	R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);
	push loop;
	R0 = R0 - 1;
	IF NE JUMP(.restore_loop_start_turnto);
.restore_loop_end_turnto:
	R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);        //loop��ջ������status��ջ��ʼ
	R0=DM(1,I7);         //ȡR0������STATUSջ����
	modify(I7,1); 				
	R0 = R0 - 1;
	IF EQ JUMP (.restore_sts_end_turnto);			//if R0==0,jump
.restore_sts_start_turnto:
	R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
    R2=DM(3,I7);  MODE1 = R2;
    nop;nop;
    modify(I7,3); 	
	push sts;
	R0 = R0 - 1;
	IF NE JUMP  (.restore_sts_start_turnto);
.restore_sts_end_turnto:
    R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
	R2=DM(3,I7);
	R1=0x00001000;R1=NOT R1;R2=R2 and R1;//ע�⣬δ�ⷢ�����⣬�˴���ȫ���жϹرգ����˳��ж�ʱ��
//	R1=0x000004fc;R1=NOT R1;R2=R2 and R1;//��������asyn ISR��ע��ʱ���ᷢ���쳣��������������һ��
	MODE1 = R2;					
	nop;nop;
	modify(I7,3); 	
	R0=DM(1,I7);  //status��ջ������pc��ջ��ʼȡR0������PCջ����
	modify(I7,1); 				
	R0 = PASS R0;
	IF EQ JUMP (.restore_pc_end_turnto);			//if R0==0,jump
.restore_pc_start_turnto:
	push pcstk;
	R2=DM(1,I7); PCSTK = R2;
    modify(I7,1); 
	R0 = R0 - 1;
	IF NE JUMP (.restore_pc_start_turnto);
.restore_pc_end_turnto:
	nop;
//���ˣ���Ӳ��ջ����,���濪ʼ�ָ��Ĵ���ֵ
    call ___restore_all_regs;  //ͨ�üĴ�����ջ
      I12=DM(1,I7);
      modify(I7,1); 
      
      
  
      //����SOVFI�쳣��ϵͳӰ��
      /* push loop;
       push loop;
       push loop;
       push loop;
       push loop;
       push loop;
       //loop stack��������ѹ�������
       push loop;*/
       
       
       
       
       
       
       
       
       
      JUMP(M13,I12)(db);
      nop;
      bit set MODE1 0x1000;		// Enable int
   
.___asm_turnto_context.end:

/*
@----�������л�---------------------------------------------------------------
@����:  ���浱ǰ�̵߳������ģ��л������̵߳��������м���ִ�С�
@����:  new_sp���������ĵ�ջָ��
@����:  old_sp���������ĵ�ջָ���ָ�룬��&vm->stack�������ṩ��������ջָ�룬
@               sp�Ĵ����ĵ�ǰֵ����
@����:  ��
@����ԭ��: 
void __asm_switch_context(struct  tagThreadVm *new_vm,struct  tagThreadVm *old_vm)
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_switch_context;
___asm_switch_context:

    bit clr MODE1 0x1000;		// Disable int
      
	R0=DM(M7,I6);
	DM(I7,M7)=R0;              //���Ƚ����̷߳��ص�ַ���浽�����ĵ�PCλ�ô�
    call ___backup_all_regs;    //ͨ�üĴ���ѹջ
    //��ʼ��Ӳ��ջ����ѹ���߳������
	R0 = pcstkp;
	BIT TST STKYx 0x00400000;
	IF TF JUMP (PC, .save_pc_end_switch_content);
.save_pc_start_switch_content:					//��pcstkp��=0�������ζ�pc������ջ
	DM(I7,M7)=pcstk;
	pop pcstk;
	BIT TST STKYx 0x00400000;
	IF NOT TF JUMP (PC, .save_pc_start_switch_content);
.save_pc_end_switch_content:					
	DM(I7,M7)=R0;    //��R0=pcstkp��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������					
	//pc��ջ������status��ջ��ʼ
	R0 = 1;
	R2 = MODE1;  DM(I7,M7)=R2;			//�浱ǰMODE1��ASTATx��ASTATy
	R2 = ASTAT;  DM(I7,M7)=R2; 
	R2 = 0x00000000; DM(I7,M7)=R2;
	BIT TST STKYx 0x01000000;
	IF TF JUMP (PC, .save_sts_end_switch_content);
.save_sts_start_switch_content:
	pop sts;					//��Ӳ��ջ
	R2 = MODE1;DM(I7,M7)=R2;			//��MODE1��ASTATx��ASTATy
//	BIT CLR MODE1 0x1000;		//ע�⣬δ�ⷢ�����⣬�˴���ȫ���жϹرգ����˳�������ʱ��
	R2 = ASTAT;DM(I7,M7)=R2;
	R2 = 0x00000000; DM(I7,M7)=R2;
	R0 = R0 + 1;
	BIT TST STKYx 0x01000000;
	IF NOT TF JUMP (PC, .save_sts_start_switch_content);
.save_sts_end_switch_content:					
    DM(I7,M7)=R0;   //��R0��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������				
	//status��ջ������loop��ջ��ʼ
	R0 = 1;
	DM(I7,M7)=LCNTR;    // Save loop counter
	DM(I7,M7)=LADDR;    // Save loop address
	DM(I7,M7)=CURLCNTR; // Save current counter       	
	BIT TST STKYx 0x04000000;
	IF TF JUMP (PC, .save_loop_end_switch_content);
.save_loop_start_switch_content:
	pop loop;
	DM(I7,M7)=LCNTR;    // Save loop counter
	DM(I7,M7)=LADDR;    // Save loop address
	DM(I7,M7)=CURLCNTR; // Save current counter  
	R0 = R0 + 1;
	BIT TST STKYx 0x04000000;
	IF NOT TF JUMP (PC, .save_loop_start_switch_content);
.save_loop_end_switch_content:					//loop��ջ����
	put(R0);					//��R0��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������
//���ˣ���Ӳ��ջ����,����ѹջ�������
    R1=I7;
    I4=R8;
    DM(M5,I4)=R1;      //��old_vm�ĵ�ǰջָ��I7���뵽R8��ָ�ĵ�ַ��
    //���ˣ����߳��������Ѿ������棬��������ʼ���뵽���߳�
    I4=R4;            //R4���� new vm�ṹ���׵�ַ��Ҳ��new vm->stack
    I12=I4;        
    R2=DM(M6,I4);     //ȡ�����ջ��ָ��  ����������ṹ���ڶ���Ԫ��Ϊ�洢ջ��ָ��
    //������Ҫȡvm�ṹ����stack_size������� vm->stack_size�����Ա��vm�ṹ���е�4��λ��
    R0=I4;
    R1=2;
    R0=R1+R0;
    I4=R0;
    R1=DM(M6,I4); //ȡ��vm->stack_sizeֵ����������vm->stack_sizeֵ����L7��ͬʱ����ջ����ջ��L7���ջ�ײ���ֵ��B7
    L7=R1;
    R0=R2-R1;
    R0=R0+1;
    B7=R0;
    I4=I12;
    R2=DM(M5,I4);
    I7=R2;
    B6=B7;		//һ����Ҫ������
    L6=L7;
    //��ʼ����C����int_half_enable_asyn_signal,�ڵ���C����֮ǰ���������Ԥ������
    R2=I6;
    I6=I7;
    I12=_Int_HalfEnableAsynSignal;
    JUMP(M13,I12)(DB);
    DM(I7,M7)=R2;
    DM(I7,M7)=PC;
   //���Ȼָ�Ӳ��ջ������,��ʼ��Ӳ��ջ��ע�⣬��ʱ��Ӳ��ջ���Ѿ�Ϊ����	
    R0=DM(1,I7);
	modify(I7,1);					//ȡR0������LOOPջ����
	R0 = R0 - 1;
	IF EQ JUMP  (.restore_loop_end_switch_content);			//if R0==0,jump
.restore_loop_start_switch_content:
    R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);
	push loop;
	R0 = R0 - 1;
	IF NE JUMP (.restore_loop_start_switch_content);
.restore_loop_end_switch_content:
	R2=DM(1,I7); CURLCNTR = R2;
	R2=DM(2,I7); LADDR = R2;
	R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);        //loop��ջ������status��ջ��ʼ
	R0=DM(1,I7);         //ȡR0������STATUSջ����
	modify(I7,1); 				
	R0 = R0 - 1;
	IF EQ JUMP (.restore_sts_end_switch_content);			//if R0==0,jump
.restore_sts_start_switch_content:
    R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
    R2=DM(3,I7);  MODE1 = R2;
    nop;nop;
    modify(I7,3); 	
	push sts;
	R0 = R0 - 1;
	IF NE JUMP  (.restore_sts_start_switch_content);
.restore_sts_end_switch_content:
    R2=DM(1,I7);
    R2=DM(2,I7);  ASTAT = R2;
    nop;nop;
	R2=DM(3,I7);
	R1=0x00001000;R1=NOT R1;R2=R2 and R1;//ע�⣬δ�ⷢ�����⣬�˴���ȫ���жϹرգ����˳��ж�ʱ��
//	R1=0x000004fc;R1=NOT R1;R2=R2 and R1;//��������asyn ISR��ע��ʱ���ᷢ���쳣��������������һ��
	MODE1 = R2;					
	nop;nop;
	modify(I7,3); 	
	R0=DM(1,I7);  //status��ջ������pc��ջ��ʼȡR0������PCջ����
	modify(I7,1); 				
	R0 = PASS R0;
	IF EQ JUMP (.restore_pc_end_switch_content);			//if R0==0,jump
.restore_pc_start_switch_content:
	push pcstk;
	R2=DM(1,I7); PCSTK = R2;
    modify(I7,1); 
	R0 = R0 - 1;
	IF NE JUMP (.restore_pc_start_switch_content);
.restore_pc_end_switch_content:
	nop;
//���ˣ���Ӳ��ջ����,���濪ʼ�ָ��Ĵ���ֵ
      //�����������Ҫ��֮ǰsave��asyn�ָ�
      //ע�⣬���жϱ����ڴ˹رգ����˳�������ʱ��
      bit clr MODE1 0x1000;		// Disable int
      CJUMP _Int_ContactAsynSignal(DB);
      DM(I7,M7)=R2;
      DM(I7,M7)=PC;
      call ___restore_all_regs;  //ͨ�üĴ�����ջ
      DM(-1,I7)=I12;            // Save I12
      I12=DM(1,I7);			
      modify(I7,1);
      pop sts;
      JUMP(M13,I12)(db);
      //I12=DM(-1,I7);
      I12=DM(-2,I7);			// Restore I12   //20140114�Ķ�
      bit set MODE1 0x1000;		// Enable int
.___asm_switch_context.end:





/*
@----�������¼�����-----------------------------------------------------------
@����: ϵͳ��ʼ����ɺ��������¼����Ȳ������һ���¼�.
@����: new_vm���״��������߳̿��ƿ�ָ��
@����: ��
@����ԭ��: void __asm_start_thread(struct  tagThreadVm  *new_vm)@
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_start_thread;
___asm_start_thread:
    NOP;
.___asm_start_thread.end:

/*
@----�ж��е��������л�-------------------------------------------------------
@����:  ���汻�ж��̵߳������ģ��л������̵߳��������м���ִ�С���������Ȼ����
@       �Ϸ�����(���û���int_isr_connect�������ӵ��жϷ�����)�У�����ARM
@       �У�ȴ������svc̬
@����:  new_sp���л�Ŀ���߳�
@����:  old_sp�����ж��߳�
@����:  ��
@����ԭ��: void __asm_switch_context_int(struct tagThreadVm *new_vm,struct tagThreadVm *old_vm)@
@-----------------------------------------------------------------------------
*/
.section/pm seg_pmco;
.global ___asm_switch_context_int;
___asm_switch_context_int:
	
	bit clr MODE1 0x1000;	// 
    nop;nop;
	bit clr MODE1 0x04fc;	// Disable second register
    nop;nop;

//��ʼ��ջָ��
//	no need here

//��PC����ֵѹջ
   DM(I7,M7)=pcstk;				//
//ͨ�üĴ���ѹջ(��MODE2,USTAT1-4)
	call ___backup_all_regs;    
//��ʼѹӲ��ջ
	pop pcstk;					//���������ж�ʱpush��һ��pcֵ
	R0 = pcstkp;
	BIT TST STKYx 0x00400000;
	IF TF JUMP (PC, .save_pc_end);
.save_pc_start:
    DM(I7,M7)=pcstk;	//��pcstkp��=0�������ζ�pc������ջ
	pop pcstk;
	BIT TST STKYx 0x00400000;
	IF NOT TF JUMP (PC, .save_pc_start);
.save_pc_end:					
	DM(I7,M7)=R0;   //��R0=pcstkp��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������				
	R0 = 1;       //pc��ջ������status��ջ��ʼ
//	pop sts;
	R2 = MODE1;					//�浱ǰMODE1��ASTATx��ASTATy
	R1=0x00001000;R2=R2 or R1;
	DM(I7,M7)=R2;
	R2 = ASTAT;  DM(I7,M7)=R2; 
	R2 = 0x00000000; DM(I7,M7)=R2; 
	BIT TST STKYx 0x01000000;
	IF TF JUMP (PC, .save_sts_end);
.save_sts_start:
	pop sts;					//��Ӳ��ջ
	R2 = MODE1;   DM(I7,M7)=R2; 			//��MODE1��ASTATx��ASTATy
	BIT CLR MODE1 0x1000;		//ע�⣬δ�ⷢ�����⣬�˴���ȫ���жϹرգ����˳��ж�ʱ��
	R2 = ASTAT;DM(I7,M7)=R2; 
	R2 = 0x00000000; DM(I7,M7)=R2; 
	R0 = R0 + 1;
	BIT TST STKYx 0x01000000;
	IF NOT TF JUMP (PC, .save_sts_start);
.save_sts_end:					
	DM(I7,M7)=R0;  	//��R0��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������				
	//status��ջ������loop��ջ��ʼ
	R0 = 1;
	DM(I7,M7)=LCNTR;
	DM(I7,M7)=LADDR;
	DM(I7,M7)=CURLCNTR;
	BIT TST STKYx 0x04000000;
	IF TF JUMP (PC, .save_loop_end);
.save_loop_start:
	pop loop;
	DM(I7,M7)=LCNTR;
	DM(I7,M7)=LADDR;
	DM(I7,M7)=CURLCNTR;
	R0 = R0 + 1;
	BIT TST STKYx 0x04000000;
	IF NOT TF JUMP (PC, .save_loop_start);
.save_loop_end:					//loop��ջ����
	DM(I7,M7)=R0;					//��R0��ջ���ڳ�ջʱ����ݴ�ֵ�ж�ѭ������
//���ˣ���Ӳ��ջ����,����ѹջ�������
    R1=I7;
//ע�⣬�����ж��е��߳��л����ԣ���Ϊ������ͨ���ڶ��׼Ĵ������ݽ����ģ�
//��ˣ������������ʹ�ܵڶ��׼Ĵ�����R0-R8������ȡnew vmֵ��Ȼ���ٻ�ԭ
	bit set MODE1 0x0080;	// Enable second R0-R7 register
    nop;nop;
    I4=R8;            //R4���� new vm�ṹ���׵�ַ��Ҳ��new vm->stack
	bit clr MODE1 0x0080;	// Disable second R0-R7 register
    nop;nop;
    DM(M5,I4)=R1;      //��old_vm�ĵ�ǰջָ��I7���뵽R8��ָ�ĵ�ַ��
//���ˣ����߳��������Ѿ������棬��������ʼ���뵽���߳�
    
//��ʼ��ջָ��
//ע�⣬�����ж��е��߳��л����ԣ���Ϊ������ͨ���ڶ��׼Ĵ������ݽ����ģ�
//��ˣ������������ʹ�ܵڶ��׼Ĵ�����R8-R15������ȡnew vmֵ��Ȼ���ٻ�ԭ
	bit set MODE1 0x0400;	// Enable second R8-R15 register
    nop;nop;
    I4=R4;            //R8���� old vm�ṹ���׵�ַ��Ҳ��old vm->stack
	bit clr MODE1 0x0400;	// Disable second R8-R15 register
    nop;nop;
    
    I12=I4;        
    R2=DM(M6,I4);     //ȡ�����ջ��ָ��  ����������ṹ���ڶ���Ԫ��Ϊ�洢ջ��ָ��
    //������Ҫȡvm�ṹ����stack_size������� vm->stack_size�����Ա��vm�ṹ���е�4��λ��
    R0=I4;
    R1=2;
    R0=R1+R0;
    I4=R0;
    R1=DM(M6,I4); //ȡ��vm->stack_sizeֵ����������vm->stack_sizeֵ����L7��ͬʱ����ջ����ջ��L7���ջ�ײ���ֵ��B7
    L7=R1;
    R0=R2-R1;
    R0=R0+1;
    B7=R0;
    I4=I12;
    R2=DM(M5,I4);
    I7=R2;
      B6=B7;		//һ����Ҫ������
      L6=L7;
  
/*    //��ʼ����C����int_half_enable_asyn_signal,�ڵ���C����֮ǰ���������Ԥ������
    R2=I6;
    I6=I7;
    I12=_Int_HalfEnableAsynSignal;
    JUMP(M13,I12)(DB);
    DM(I7,M7)=R2;
    DM(I7,M7)=PC;
	*/
//��ʼ��Ӳ��ջ��ע�⣬��ʱ��Ӳ��ջ���Ѿ�Ϊ����	
	R0=DM(1,I7);    //ȡR0������LOOPջ����
    modify(I7,1);
	R0 = R0 - 1;
	IF EQ JUMP (.restore_loop_end);			//if R0==0,jump
.restore_loop_start:
    R2=DM(1,I7); CURLCNTR = R2;
    R2=DM(2,I7); LADDR = R2;
    R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);
	push loop;
	R0 = R0 - 1;
	IF NE JUMP (.restore_loop_start);
.restore_loop_end:
	R2=DM(1,I7); CURLCNTR = R2;
    R2=DM(2,I7); LADDR = R2;
    R2=DM(3,I7); LCNTR = R2;
	modify(I7,3);
	//loop��ջ������status��ջ��ʼ
	R0=DM(1,I7);    //ȡR0������STATUSջ����
	modify(I7,1);				
	R0 = R0 - 1;
	IF EQ JUMP (.restore_sts_end);			//if R0==0,jump
.restore_sts_start:
    R2=DM(2,I7); ASTAT = R2;
    nop;nop;
    R2=DM(3,I7); MODE1= R2;
    nop;nop;
	modify(I7,3);
	push sts;
	R0 = R0 - 1;
	IF NE JUMP (.restore_sts_start);
.restore_sts_end:
    R2=DM(2,I7); ASTAT = R2;
	nop;nop;
	R2=DM(3,I7);
	R1=0x00001000;R1=NOT R1;R2=R2 and R1;//ע�⣬δ�ⷢ�����⣬�˴���ȫ���жϹرգ����˳��ж�ʱ��
	R1=0x000004fc;R1=NOT R1;R2=R2 and R1;//��������asyn ISR��ע��ʱ���ᷢ���쳣��������������һ��
	MODE1 = R2;					
	nop;nop;
	modify(I7,3);    //ignore 1 . reserve				
	//status��ջ������pc��ջ��ʼ
	R0=DM(1,I7);    //ȡR0������PCջ����
    modify(I7,1);
	R0 = PASS R0;
	IF EQ JUMP (.restore_pc_end);			//if R0==0,jump
.restore_pc_start:
	push pcstk;
	R2=DM(1,I7); pcstk=R2;
	modify(I7,1);
	R0 = R0 - 1;
	IF NE JUMP (.restore_pc_start);
.restore_pc_end:
	nop;
//���ˣ���Ӳ��ջ����,���濪ʼ�ָ��Ĵ���ֵ
//��������ǲ���Ҫ����ʹ��asyn
//ͨ�üĴ�����ջ(��MODE2,USTAT1-4)
	call ___restore_all_regs;
	
	//α����ж�ʱPCSTK��״̬
	push pcstk;
	pcstk=DM(1,I7);
	modify(I7,1);
	//���ˣ�����͵������������ɣ����Է�����
	bit set MODE1 0x04fc;	// Enable second register
    nop;nop;
    
    I12=DM(M7, I6);
    JUMP (M14,I12)(DB);
    rframe;
    nop;
    

.___asm_switch_context_int.end: