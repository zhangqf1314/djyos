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
// ģ������: ��CPU�������ĳ�ʼ����Ϊϵͳ��ʼ����������׼��
// ģ��汾: V1.00
// ������Ա: Administrator
// ����ʱ��: 2013--����5:14:20
// =============================================================================
// �����޸ļ�¼(���µķ�����ǰ��):
// <�汾��> <�޸�����>, <�޸���Ա>: <�޸Ĺ��ܸ���>
// =============================================================================
.file  "CpuStarts.S"
#include "E500V2Reg.h"
#include "E500V2RegBits.h"
.align 4
.text
.global  __AsmRamStart
__AsmRamStart:

    //����UBOOT�����ǵĳ�ʼ���������Ȳ�����
    //���ˣ����ǿ�ʼ����DJYOS������ϣ��һ�ж����µģ�����MMU
    //���MSR,�ر�һ���жϺ��쳣
    lis   r3, CN_MSR_INIT@h  //de  spe
    ori  r3, r3, CN_MSR_INIT@l
    mtmsr r3
    isync

    //����spΪ�û�sp
    lis  sp, usr_top@h
    ori  sp,sp, usr_top@l
    subi sp, sp, 0x20


    //����TCR���رն���������в��DTIMER/FIXTIMER
    xor  r5, r5, r5
    mtspr tcr, r5
    //���TSR��־����Ҫ����TIMER��ǰ���쳣
    mtspr tsr, r5
    //clear the db exception bits
    mtspr  dbsr , r5
    isync
    //clear the esr exception
    mtspr  esr, r5
    isync

    //����trap,���ÿ���trap�ˣ����Ǹ�������ҪTRAP�ˣ���SC�͹���
    //dbcr0�кܶ�debug�쳣ʹ�ܣ�Ϊ�˷��㣬���еĶ��رգ�����trap
    lis  r6, cn_dbcr0_debug_mode@h
    ori r6, r6, cn_dbcr0_debug_mode@l
    mtspr  dbcr0,  r6
    isync

    //����TIMERҪ�� �ļĴ���Ҫ����һ�°ɣ�������
    //�Ժ���Ҫ��ʲô���Լ�Ūʲô��ֻ�����Լ�
    //clear all the hid
    //OPERATE THE HIDX NEED SYNC OPERATE
    xor  r3, r3, r3
    msync
    isync
    mtspr  hid0, r3
    isync
    msync
    isync
    mtspr  hid1, r3
    isync
    //��EMCP,ʹ��mcp����MC�쳣
    mfspr  r3, hid0
    lis    r4, HID0_EMCP@h
    ori    r4, r4, HID0_EMCP@l
    or     r3, r4, r3
    msync
    isync
    mtspr  hid0, r3
    isync
    //������MC�쳣����ASSERT_sreset����core_fault_in�źŽ���core�����쳣
    mfspr  r3, hid1
    lis    r4, HID1_RFXE@h
    ori    r4, r4, HID1_RFXE@l
    or     r3, r4, r3
    msync
    isync
    mtspr  hid1, r3
    isync
    //���һЩ��Ҫ�ļ�����
    xor  r6, r6, r6
    mtspr dec, r6
    isync
    mtspr  decar, r6
    isync
    mtspr tbl_write, r6
    isync
    mtspr tbu_write, r6
    isync
    mtspr tcr, r6
    isync
    //����spefscr
    xor r3, r3, r3
    li  r3, 0x3C
    mtspr spefscr, r3
    isync

    
    //do the cpu init
    bl CpuInit
    //����ɣ����꣡
    //start the os code
    bl  Load_Preload

  /*
@-------------------------------------------------------------------------------
@����: ��L1cache
@����:
@����:
@����ԭ��:__AsmDisL1Cache(void)
@-------------------------------------------------------------------------------
*/
/*first invalidate, then disable*/
//first icache, the dcache
//invalidate l1icache
.global  __AsmDisL1Cache
__AsmDisL1Cache:

    stwu sp, -32(sp)
    stw  r0, 8(sp)
    stw  r3, 12(sp)
    stw  r4, 16(sp)
    stw  r5, 20(sp)
    msync
    //first disable it, then invalid it
    //icache
    lis      r5, cn_l1csr1_ice@h
    ori      r5, r5, cn_l1csr1_ice@l
    mfspr    r4, l1csr1
    andc     r4, r4, r5
    mtspr    l1csr1, r4
    lis      r3, cn_l1csr1_icfi@h
    ori      r3, r3, cn_l1csr1_icfi@l
    isync
    msync
    mtspr    l1csr1, r3
l1i_invalid_loop:
    mfspr    r4, l1csr1
    and.     r4, r4, r3
    bgt      l1i_invalid_loop

    //dcache
    lis      r5, cn_l1csr0_ce@h
    ori      r5, r5, cn_l1csr0_ce@l
    mfspr    r4, l1csr0
    andc     r4, r4, r5
    mtspr    l1csr0, r4
    lis      r3, cn_l1csr0_cfi@h
    ori      r3, r3, cn_l1csr0_cfi@l
    isync
    msync
    mtspr    l1csr1, r3
l1d_invalid_loop:
    mfspr    r4, l1csr0
    and.     r4, r4, r3
    bgt      l1i_invalid_loop


    lwz r0, 8(sp)
    lwz r3, 12(sp)
    lwz r4, 16(sp)
    lwz r5,20(sp)
    lwz sp,0(sp)
    blr    

.end


