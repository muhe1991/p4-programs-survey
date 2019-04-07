# HyperV: High-Performance Virtualization of the Programmable Data Plane


## NOTICE

As the codebase of HyperV has changed a lot since ICCCN'17, the [test cases](/tests) are not modified accordingly. So we are not sure that the test cases can work. However, we provide a [runtime controller](https://github.com/HyperVDP/HyperV-Controller.git) which provisions a high-level abstraction of HyperV based on [P4Runtime](https://github.com/p4lang/PI). We will give a logn-term support to the runtime controller. Thus we recommand you to use the runtime controller to manage the hypervisor. If you have any question, please refer Cheng Zhang at [cheng-zhang13@mails.tsinghua.edu.cn](cheng-zhang13@mails.tsinghua.edu.cn), or Yu Zhou at [y-zhou16@mails.tsinghua.edu.cn](y-zhou16@mails.tsinghua.edu.cn). We are very glad to offer our help and will try our best to answer your questions.

## About HyperV

 HyperV is a high-performance hypervisor provisions non-exclusive data plane abstraction and uninterrupted reconfigurability for the programmable data plane.

 ## The project

### [src](/src)

The source code of HyperV.

### [tests](/tests)

The test cases for HyperV.

### [tools](/tools)

The scripts for creating the testing environment.

