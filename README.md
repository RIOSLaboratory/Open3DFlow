
# Open3DFlow

Open3DFlow is a open source 3D IC design flow. This work starts in 2022. And now we are working for the second generation Open3DFlow.

We hope this work could accelerate the development of 3D IC and the open source education. And make an effort on open source EDA tools. 
![image](https://github.com/user-attachments/assets/0baa25c6-62ad-4b42-8ac3-290e81a81636)


Amid the escalating need for high-performance, low-power, and densely integrated electronic systems, 3D-ICs emerge as a promising "more than Moore'' integration solution. Nevertheless, the scarcity of specialized EDA tools and standardized design flows tailored for 3D chiplets hinders silicon innovation. To address this gap, we propose a 3D RISC-V processor, mimicking AMD's 3D V-cache architecture. To realize this architecture, we develop 'Open3DFlow', an open-source 3D IC design platform that leverages existing openEDA tools while incorporating tailored abstractions and customizations optimized for 3D chiplet designs. 



Besides OpenROAD, we also integrate other open tools to enable Through Silicon Via (TSV) modeling, thermal analysis, and signal integrity (SI) assessments. Our CPU consists of two tiers: a cache die and a logic die, stacked face-to-face (F2F) using different processes. The interconnects converge at the central bonding layer, where the bonding pads are located. Our ambition is to establish a fully open-source realization of cutting-edge technologies, not only to facilitate the resolution of future challenges within this platform but also to pave the way for the exploration of novel packaging paradigms.

![image](https://github.com/user-attachments/assets/98607fbb-89c5-47cf-af92-baddd38d7349)


## 1.   Introduction and Spec
In the realm of microelectronics, the pursuit of superior performance, energy efficiency, optimized space utilization, and economical solutions has spurred the development of novel integration techniques. Given the need for semiconductor memory chips with higher density to support recently released CPU components, the technique for advanced packages has emerged as a promising solution.

The technological trend can be roughly divided into four stages:    
- 2D package, with solder balls or bumps as the representative connection method. (Flip chip, wire bonding)
- Wafer Level Packaging, utilizing Redistribution Layer (RDL) as the representative connection approach. (INFO-PoP, eWLB)
- 2.5D package, typically based on interposer or Embedded Multi-die Interconnect Bridge. (EMIB, CoWoS-x)
- 3D stacking, employing hybrid bonding and Through Silicon Vias (TSVs) for signal and power transmission. (3D SoIC)

As depicted in the following diagram, the trend consistently leans towards achieving greater integration and shorter interconnection distances:

![image](https://github.com/user-attachments/assets/1983fc7a-2a19-48a7-919a-d8cbe3041aba)


Currently, the 3D IC flow faces several limitations. Primarily, it relies heavily on 2D tools and lacks comprehensive thermal analysis as well as power and signal integrity (SI) assessments. And because there are knowledge gaps between chip design and packaging. Modeling for 3D items such as TSVs and bonding pads hardly exists in IC back-end processes. Additionally, due to the immature and closed nature of existing 3D design EDA tools, future designs face challenges in integrating with large models and cloud platforms. Commercial licensing costs and limitations on processor scalability in cloud environments further complicate the matter.

To address these issues, in the work, we present our own 3D IC design methodology. We develop a 5-stage-pipeline RISC-V CPU with its cache die stacking on the logic die, which mimics AMD's 3D V-cache architecture. We incorporate openPDKs and openEDA tools while doing the hardening. For that end, we propose an open source 3D chip EDA design platform with TSV and thermal modeling named 'Open3DFlow'. It is also the first fully open-source process for designing 3D chips, which is poised to significantly contribute to the vibrant growth of the open-source community. Our goal is to tape out this design through the OpenMPW program, and the process will be easily extended to include logic+DRAM or logic+logic configurations. 

The significance of this work can be summarized:
1.  We build a 3D RISC-V chip in fully open-source mode, leveraging open EDA tools, incorporating hybrid bonding and TSV technologies.
2.  we propose 'Open3DFlow', an open source EDA platform that offers comprehensive TSV/Chip's SI and thermal analysis, ensuring reliable and efficient 3D IC designs
3.  The open-source nature facilitates seamless integration with AI, large models, and cloud computing, boosting design efficiency for complex 3D ICs.

4.      Architecure Specification：
We employ a five-stage pipelined RISC-V CPU equipped with an L1 cache to demonstrate our 3D IC design flow. In the future, we will transition towards more intricate designs to co-optimize our toolchains. The core was created for an OSU undergraduate course in July 2019, we have modified it to fit for our 3D design flow. Here we summarize the key features:
- 32-bit CPU RISC-V supporting I extension 
- 5-stage pipeline in-order execution
- 1KB L1 cache concatenate by 4 sram macros
- PDK for logic die：SkyWater 130nm (Sky130A)
- PDK for cache die: GlobalFoundries 180nm (GF180)
- Connection methods: bonding pads for hybrid bonding & TSV

![image](https://github.com/user-attachments/assets/b0635530-9a2e-40b2-b3b9-9ef82b50f6ed)


## 2. EDA Toolchain in Open3DFlow
### 2.1 Open3DFlow Infrastructure
’Open3DFlow‘ incorporates a range of open EDA tools tailored for distinct stages of the design process. As shown in the following figure：

![image](https://github.com/user-attachments/assets/fb551f11-9b09-47c2-83f0-0881f032ddc5)



Within green boxes are existing open-source tools/algorithms such as Yosys and RePlace, which have been integrated into OpenRoad. The purple boxes represent the new open-source EDA tools we add to our design process. While the red boxes highlight our self-developed modules: 
1. Pad placer generates a bonding layer, placing bonding pads and ensuring alignment between two tiles; 
2. 3D Times extracts the delay introduced by TSVs, incorporating it into the subsequent CTS process. 
3. Route helper manages routing connections between metal layers and bonding pads, while also extracting parasitic parameters associated with the chiplets.

### 2.2 3D Back-end Design Flow
To achieve this design, we developed a platform called 'Open3DFlow'. 'Open3DFlow' integrates a range of open-source tools and provides apt abstractions, augmented with specialized modules designed to simulate the 3D structure of hybrid bonding. Notably, the 2D backend of the chip leverages certain components from the existing workflow in OpenRoad.

The overall workflow of 'Open3DFlow' is depicted in this figure:

![image](https://github.com/user-attachments/assets/cd7443e3-5036-4cbb-876b-36470e41c2db)


In the initial phase, we synthesize the RTL codes of the processor and V-cache to generate netlists respectively. They are synthesized using distinct PDKs.

Subsequently, we proceed to do floorplanning of both dies. The footprints of the two dies must be aligned with each other.

The next step involves the placement of standard cells and bonding pads. A key aspect of hybrid bonding is its transition from solder-based bump technology to direct copper-to-copper connections. So we introduce a dedicated 'bonding layer' for bonding pads. However, modifying the technology file of the full metal stack can introduce complexities in Design Rule Check (DRC) rules and RC extraction schedules. To maintain a reasonable F2F stacking structure, actually, the top layer of the V-cache die serves as the bonding layer. Consequently, this metal layer is not allowed for routing. Simultaneously, this bonding layer is integrated into the metal stack of the logic die. We have extracted the RLC characteristics and related dimensions of two die's all metal layers to construct the 3D chips' full backend-of-the-line (BEOL). Compared to other monolithic-3D methods, this approach simplifies modifications to the logic die's tlef, as we do not require actual routing on the bonding layer, just sacrificing the routing resources of the cache die.

Besides, the placement and legalization of stand cells are also involved at this stage, ensuring that the bonding pads of both dies align automatically.

Then, we model the delays and impedances introduced by 3D items such as bumps, TSVs, and bonding pads. The TSVs connect the upper bonding pads to the bumps, which interface with the RDL or package substrate. Delays can be abstracted and concentrated at their IOs. Detailed modeling will be discussed in the next section.

Next, the logic die and V-cache die are routed separately to obtain the final GDSII files. Although routing is performed individually for each die, the alignment of bonding pads, the parasitic parameters and time delays for 3D structure, obtained in the previous step, validate this flow for the final F2F-stacked 3D chip architecture. Even though it is relatively straightforward to change the two back-end processes to run in parallel, the main consideration is that the positions of the bonding pads should be routable for both dies. However, at present, we manually select their positions.

In the last two steps, we perform thermal simulation and SI analysis based on chip dimensions, power consumption, and other relevant parameters. Thermal simulations allow us to accurately assess the heat distribution within the chip, enabling us to optimize the cooling system in the future. The SI analysis helps identify potential electromagnetic interference issues.


## 3.   Architecture Design of 3D RISC-V Processor with V-Cache
### 3.1 Chiplet Consideration
There are some typical structures for 3D processors. As depicted in the following figure:

![image](https://github.com/user-attachments/assets/9d7c99d8-3601-4f36-9ddf-4a5d33b059f3)


(a) depicts combinations of multiple packages; (b) represents 2.5D IC, applying passive or active interposers; (c) illustrates for DRAMs on logic dies; (d) stacks one logic circuit on another; and in (d), SRAMs are positioned beneath the logic but for (f), the logic is on the upper side. 

说明：sram与logic共用interposer，以及hbm在logic上的，都是学生瞎写的

However, modern 3D processor architectures often combine multiple stacking approaches. The prevailing trend in 3D architecture evolution is towards increased density integration, reduced micro-bumps and TSV pitches, as well as shorter chiplet distances. For instance, AMD's 3D-Vcache does not follow the traditional approach of placing caches alongside the processor; instead, it stacks additional cache layers on top of the CPU. This architecture enables AMD to compress more cache without fabricating larger CPUs, resulting in improved speed and power efficiency in gaming applications. To achieve broader bandwidth and faster transmission speeds, the hybrid bonding technology even eliminates bumps. In our design, we select the "CPU + Caches" structure for experimentation. We aim to develop a fully open-source 3D-Vcache structure utilizing openEDA tools and openPDKs. Our aspiration is also to establish a platform that can be flexibly extended to other stacking modes in the future.

### 3.2 V-Cache Structure
The L1 cache is composed by concatenating 4 GF180 256*8-SRAM  macros, utilizing a 7-bit address for both reading and writing operations. As shown in this figure:


![image](https://github.com/user-attachments/assets/1c73ccfe-bbc4-492f-89a5-21aab7abeb26)


All signals related to this cache die, excluding the clock signal, establish direct communication with the logic die via bonding pads and TSVs. The floorplan for the macros is manually crafted. The two ties possess their own independent power supply networks, but converge on the logic die. Detailed insights into the back-end design are outlined in the subsequent sections.

### 3.3  RISC-V CPU with 3D Stacking SRAM
The overall stacked architecture is illustrated as:

![image](https://github.com/user-attachments/assets/f771da4e-beed-485c-bed8-66a92d562bde)


In our study, two dies are stacked in a F2F configuration, which means that their corresponding connection signal points converge onto the same bonding pads on the bonding layer. Additionally, the TSVs are via-last fabricated, where they reach the topmost layer of the top die and penetrate through all the metal layers of the sub die. Finally, the entire 3D chip is mounted on the substrate using flip-chip packaging with solder bumps.

</br>

### 4  Versions

|Version|Description|
|:--:|:----------:|
| V1 | initial version of Open3DFlow, only support basic TSV model, not accurcy in thermal and routing|
| V2 |                      |
|    |                      |


#### Team Members

|Name|Affiliation|
|:--:|:----------:|
| Zhangxi Tan (xtan@rioslab.org)| Doctor, RIOS Lab, Tsinghua-Berkeley Shenzhen Institute, Tsinghua University|
| Weiwei Chen (weiwei.c@rioslab.org)| Scientist, RIOS Lab, Tsinghua-Berkeley Shenzhen Institute, Tsinghua University|
| Lei Ren (ren@rioslab.org)| Scientist, RIOS Lab, Tsinghua-Berkeley Shenzhen Institute, Tsinghua University|
| Yifei and other students| Students of RIOS Lab, Tsinghua-Berkeley Shenzhen Institute, Tsinghua University|



</br>

</br>

</br>









