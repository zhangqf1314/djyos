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
//����ģ��:  CPU��ʼ��
//���ߣ�     Liuwei
//�汾��      V1.0.0
//��ʼ�汾������ڣ�2015-06-01
//�ļ�����:  cpuʱ�ӳ�ʼ��
//����˵��:  ��
//�޶���ʷ:
//2. ...
//1. ����: 2015-06-01
//   ����: Liuwei
//   �°汾�ţ�V1.0.0
//   �޸�˵��: ԭʼ�汾
//------------------------------------------------------
#include "arch_feature.h"
#include "stdint.h"
#include "cpu_peri.h"
#include "hard-exp.h"
#include "sysctl.h"
#include "MMU.h"



#if 0 //for led_debug
void _start(void);

void    x_led_test(void)
{
    //PB5,6,7,8;
    register struct gpio_reg *gpio;
    register volatile int i;
    ////register volatile int j;

    //i = &_start;

    gpio =(struct gpio_reg*)GPIO_REG_BASE;

    gpio->GPBCON &= ~((3<<16)|(3<<14)|(3<<12)|(3<<10));
    gpio->GPBCON |=  ((1<<16)|(1<<14)|(1<<12)|(1<<10));

    //j=0;
    //while(j++ < 50000)
    while(1)
    {
        gpio->GPBDAT &= ~((1<<8)|(1<<7)|(1<<6)|(1<<5));
        for(i=0;i<0x00040000;i++);

        gpio->GPBDAT |=  ((1<<8)|(1<<7)|(1<<6)|(1<<5));
        for(i=0;i<0x00040000;i++);
    }

}
#endif


// ---- ��ʼ��MMU ----
void MMU_Init(void)
{
        MMU_MapSection(mmu_page_table,0x00000000,0x00000000,4096,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB));

        MMU_MapSection(mmu_page_table,0x08000000,0x08000000,32,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB)); //BANK1(����)

        MMU_MapSection(mmu_page_table,0x10000000,0x10000000,32,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB)); //BANK2(CAN)

        MMU_MapSection(mmu_page_table,0x20000000,0x20000000,32,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB)); //BANK4

        MMU_MapSection(mmu_page_table,0x30000000,0x30000000,8,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,CNB));  //ROM1

        MMU_MapSection(mmu_page_table,0x30800000,0x30800000,8,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB)); //RAM_nocache

        MMU_MapSection(mmu_page_table,0x31000000,0x31000000,16,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,CNB));  //RAM1

        MMU_MapSection(mmu_page_table,0x32000000,0x32000000,16,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,CNB));  //RAM2

        MMU_MapSection(mmu_page_table,0x33000000,0x33000000,16,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,CNB));  //RAM3

        MMU_MapSection(mmu_page_table,0x48000000,0x48000000,384,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,NCNB)); //SFR

        MMU_MapSection(mmu_page_table,0xFFF00000,0x33F00000,1,
                SECTION_ATTR(AP_USER_RW,DOMAIN_NO_CHECK,CNB));  //Last 1MB


        MMU_SetSectionsBase((u32*)mmu_page_table);
        MMU_SetDomainAccess(0xffffffff);          //��������й�����Ȩ��


}

#if (CN_CFG_FIN_CLK==(8*Mhz))
#define PLL_200MHZ  (192<<12)|(2<<4)|(1<<0)  //For Fin=8M
#endif

#if (CN_CFG_FIN_CLK==(12*Mhz))
#define PLL_200MHZ  (92<<12)|(4<<4)|(0<<0)   //For Fin=12M
#endif


void CPU_CLKInit(void)
{
    volatile register int i;
    struct SYSCON_REG *sys =SYSCON_REG_BASE;

    sys->LOCKTIME = 0x0FFFFFFF;

    sys->CAMDIVN = 0;
    sys->CLKDIVN =  (1<<bo_clkdivn_udivn)    //uclk = upll���/2
                   |(1<<bo_clkdivn_hdivn)    //hclk = fclk/2=100M
                   |(1<<bo_clkdivn_pdivn);   //pclk = hckk/2=50M

    for(i=0;i<50;i++);
    sys->MPLLCON =  PLL_200MHZ;
    for(i=0;i<1000;i++);


}



void MEM_BUSInit(void)
{

    struct MEMCON_REG *mem=MEMCON_REG_BASE;
    register vu32 xr0;

    xr0  = mem->BWSCON;
    xr0 &= 0x00FFF000;       //���bank0,bank1,bank2,bank6/7

    xr0 |=   (0<<bo_bus_ublb_bank7)
            |(0<<bo_bus_wait_bank7)
            |(2<<bo_bus_width_bank7)

            |(0<<bo_bus_ublb_bank6)
            |(0<<bo_bus_wait_bank6)
            |(2<<bo_bus_width_bank6)

            //BANK2:CAN,8bit
            |(0<<bo_bus_ublb_bank2)
            |(0<<bo_bus_wait_bank2)     //BANK2 wait disable
            |(0<<bo_bus_width_bank2)    //BANK2 0:8bit; 1:16bit;

            //BANK1:����,16bit
            |(0<<bo_bus_ublb_bank1)
            |(0<<bo_bus_wait_bank1)     //BANK1 wait disable
            |(1<<bo_bus_width_bank1);   //BANK1 0:8bit; 1:16bit;

    mem->BWSCON = xr0;

    mem->BANKCON0 =  (3<<bo_bankcon_tacs)
                    |(3<<bo_bankcon_tcos)
                    |(6<<bo_bankcon_tacc)
                    |(3<<bo_bankcon_tcoh)
                    |(3<<bo_bankcon_tcah)
                    |(1<<bo_bankcon_tacp)
                    |(0<<bo_bankcon_pmc);

    mem->BANKCON1 =  (3<<bo_bankcon_tacs)
                    |(3<<bo_bankcon_tcos)
                    |(6<<bo_bankcon_tacc)
                    |(3<<bo_bankcon_tcoh)
                    |(3<<bo_bankcon_tcah)
                    |(1<<bo_bankcon_tacp)
                    |(0<<bo_bankcon_pmc);

    mem->BANKCON2 =  (3<<bo_bankcon_tacs)
                    |(3<<bo_bankcon_tcos)
                    |(6<<bo_bankcon_tacc)
                    |(3<<bo_bankcon_tcoh)
                    |(3<<bo_bankcon_tcah)
                    |(1<<bo_bankcon_tacp)
                    |(0<<bo_bankcon_pmc);


    mem->BANKCON4 = (3<<bo_bankcon_tacs)
                                  +(3<<bo_bankcon_tcos)
                                  +(6<<bo_bankcon_tacc)
                                  +(3<<bo_bankcon_tcoh)
                                  +(3<<bo_bankcon_tcah)
                                  +(1<<bo_bankcon_tacp)
                                  +(0<<bo_bankcon_pmc);
    mem->BANKCON6 = (3<<bo_b67_mt)
                                  +(0<<bo_b67_trcd)
                                  +(1<<bo_b67_scan);
    mem->BANKCON7 = (3<<bo_b67_mt)
                                  +(0<<bo_b67_trcd)
                                  +(1<<bo_b67_scan);
    mem->REFRESH = (1<<bo_refresh_refen)
                                 +(0<<bo_refresh_trefmd)
                                 +(0<<bo_refresh_trp)
                                 +(1<<bo_refresh_trc)
                                 +(0<<bo_refresh_tchr)
                                 +(SDRAM_refresh_time<<bo_refresh_refcnt);
    mem->BANKSIZE = (0<<bo_banksize_bursten)
                                  +(1<<bo_banksize_sckeen)
                                  +(1<<bo_banksize_sclken)
                                  +(1<<bo_banksize_size);
    mem->MRSRB6 = 3<<bo_mrsrb_cl;
    mem->MRSRB7 = 3<<bo_mrsrb_cl;
}
