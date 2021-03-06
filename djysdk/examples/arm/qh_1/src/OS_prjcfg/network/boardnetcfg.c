//-----------------------------------------------------------------------------
// Copyright (c) 2014, SHENZHEN PENGRUI SOFT CO LTD. All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. As a constituent part of djyos,do not transplant it to other software
//    without specific prior written permission.

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
// Copyright (c) 2014 著作权由深圳鹏瑞软件有限公司所有。著作权人保留一切权利。
//
// 这份授权条款，在使用者符合以下三条件的情形下，授予使用者使用及再散播本
// 软件包装原始码及二进位可执行形式的权利，无论此包装是否经改作皆然：
//
// 1. 对于本软件源代码的再散播，必须保留上述的版权宣告、本条件列表，以
//    及下述的免责声明。
// 2. 对于本套件二进位可执行形式的再散播，必须连带以文件以及／或者其他附
//    于散播包装中的媒介方式，重制上述之版权宣告、本条件列表，以及下述
//    的免责声明。
// 3. 本软件作为都江堰操作系统的组成部分，未获事前取得的书面许可，不允许移植到非
//    都江堰操作系统环境下运行。

// 免责声明：本软件是本软件版权持有人以及贡献者以现状（"as is"）提供，
// 本软件包装不负任何明示或默示之担保责任，包括但不限于就适售性以及特定目
// 的的适用性为默示性担保。版权持有人及本软件之贡献者，无论任何条件、
// 无论成因或任何责任主义、无论此责任为因合约关系、无过失责任主义或因非违
// 约之侵权（包括过失或其他原因等）而起，对于任何因使用本软件包装所产生的
// 任何直接性、间接性、偶发性、特殊性、惩罚性或任何结果的损害（包括但不限
// 于替代商品或劳务之购用、使用损失、资料损失、利益损失、业务中断等等），
// 不负任何责任，即在该种使用已获事前告知可能会造成此类损害的情形下亦然。
//-----------------------------------------------------------------------------
//this file create an module that leads you how to initialize the net to match your
//board.if you want to configure the tcpip stack itself,please  cpy the tcpipconfig.cfg
//file to your user directory and modify the data as the instruction

#include <sys/socket.h>
#include "cpu_peri.h"     //for the k70 net device in the soc
const char *gNetDevName = "k70eth";

//please refers the following function in the module-trim in proper place.
//make sure that that os kernel has been initialize ok and the interrupt system intialize ok
//make sure that that board net hardware has initialized and could work ok
ptu32_t ModuleInstall_BoardNetStaic(ptu32_t para)   //static ip example
{
    //install the tcpip stack
    ModuleInstall_TcpIp(0);
	//install the net device you used,you could use more than one, but they
	//has different names and macs
    //use the corresponding net device install function you use
//    extern bool_t ModuleInstall_Enet(ptu32_t para);
//    tagEnetCfg EnetCfg = {gNetDevName,MAC_RMII,AUTONEG_ON,MII_100BASET,
//                          MII_FDX,NO_LOOPBACK,EXTERNAL_NONE,0,
//                          {0x00,0x01,0x02,0x03,0x04,0x03}};
//    ModuleInstall_Enet((ptu32_t)&EnetCfg);

    //make an link rout for the netdeb you installed,you could install more
	//than one link rout for the same net device with different net address
	tagHostAddrV4  ipv4addr;
	//we use the static ip we like
	memset((void *)&ipv4addr,0,sizeof(ipv4addr));
	ipv4addr.ip      = inet_addr("192.168.0.179");
	ipv4addr.submask = inet_addr("255.255.255.0");
	ipv4addr.gatway  = inet_addr("192.168.0.1");
	ipv4addr.dns     = inet_addr("192.168.0.1");
	ipv4addr.broad   = inet_addr("192.168.0.255");
	if(RoutCreate(gNetDevName,EN_IPV_4,(void *)&ipv4addr,CN_ROUT_NONE))
	{
	   printk("%s:Add %s success\r\n",__FUNCTION__,gNetDevName);
	}
	else
	{
		printk("%s:Add %s failed\r\n",__FUNCTION__,gNetDevName);
	}

	return 0;
}

ptu32_t ModuleInstall_BoardNetDynamic(ptu32_t para)   //use the dhcp to malloc an ip dynamic
{
    //install the tcpip stack
    ModuleInstall_TcpIp(0);
	//install the net device you used,you could use more than one, but they
	//has different names and macs
    //use the corresponding net device install function you use
//    extern bool_t ModuleInstall_Enet(ptu32_t para);
//    tagEnetCfg EnetCfg = {gNetDevName,MAC_RMII,AUTONEG_ON,MII_100BASET,
//                          MII_FDX,NO_LOOPBACK,EXTERNAL_NONE,0,
//                          {0x00,0x01,0x02,0x03,0x04,0x03}};
//    ModuleInstall_Enet((ptu32_t)&EnetCfg);

    //make an link rout for the netdeb you installed
    //if you will malloc the ip from the dhcp server,make sure that the dhcp client has been enabled
    //actually,you could only install one rout for the same net dev
    if(DhcpAddClientTask(gNetDevName))
    {
       printk("%s:Add %s success\r\n",__FUNCTION__,gNetDevName);
    }
    else
    {
        printk("%s:Add %s failed\r\n",__FUNCTION__,gNetDevName);
    }

	return 0;
}

