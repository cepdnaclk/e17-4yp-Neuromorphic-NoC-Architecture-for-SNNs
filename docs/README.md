---
layout: home
permalink: index.html

# Please update this with your repository name and title
repository-name: e17-4yp-Neuromorphic-NoC-Architecture-for-SNNs
title: Neuromorphic Network-on-Chip Architecture for Spiking Neural Networks
---

[comment]: # "This is the standard layout for the project, but you can clean this and use your own template"

# Neuromorphic Network-on-Chip Architecture for Spiking Neural Networks

#### Team

- E/17/018, Balasuriya I.S., [email](mailto:e17018@eng.pdn.ac.lk)
- E/17/154, Karunanayake A.I. , [email](mailto:e17154@eng.pdn.ac.lk)
- E/17/286, Rathnayaka R.M.T.N.K., [email](mailto:e17286@eng.pdn.ac.lk)

#### Supervisors

- Dr. Isuru Nawinne, [email](mailto:isurunawinne@eng.pdn.ac.lk)
- Dr. Mahanama Wickramasinghe, [email](mailto:mahanamaw@eng.pdn.ac.lk)
- Prof. Roshan Ragel, [email](mailto:roshanr@eng.pdn.ac.lk)
- Dr. Isuru Dasanayake, [email](mailto:isurud@ee.pdn.ac.lk)

#### Table of content

1. [Abstract](#abstract)
2. [Related works](#related-works)
3. [Methodology](#methodology)
4. [Experiment Setup and Implementation](#experiment-setup-and-implementation)
5. [Results and Analysis](#results-and-analysis)
6. [Conclusion](#conclusion)
7. [Publications](#publications)
8. [Links](#links)

---

## Abstract

Neuromorphic engineering is an interesting discipline
within computer science which endeavours to emulate the in-
tricate functioning of the human brain through the utilisation of very large-scale integrated (VLSI) circuits. These architectures employ artificial neurons and synapses to replicate the characteristics of the brain, including its exceptional parallelism,rapid processing capabilities, and energy efficiency achieved by virtue of a densely interconnected neural network as well as its event-driven nature. Notably, the escalating prominence of machine learning and neural networks has rendered neuromorphic architectures increasingly relevant, surpassing
the traditional von Neumann architecture employed in most
general-purpose computers. As such, exploring the potential of neuromorphic engineering holds promise for advancing com-
putational capabilities and paving the way for novel computing paradigms.

Neuromorphic computing is an interdisciplinary subject en-
compassing multiple fields such as biology, computer science,and electronic engineering. Current research in neuromorphic engineering focuses on developing neuron models inspired by biological neurons, creating hardware implementations of artificial neurons, and designing scalable neuromorphic processor architectures. These architectures consist of numerous artificial neurons organized in a densely-connected network,
often containing a large number of interconnected processing
nodes. While these architectures differ in performance and
configuration flexibility, they are generally known for their efficiency in simulating spiking neural networks. Compared to traditional computer architectures, they offer superior performance and reduced power consumption.

Our Approach represents how a Network-on-Chip (NoC) architecture based on the RISC-V instruction set architecture (ISA) which allows for hardware-level processing of spiking neural networks, and the implementation of the design on an FPGA. RISC-V was chosen
as the base ISA since it is not only highly practical and
popular, but also completely open source and amenable to
custom extensions.

The proposed design consists of customised RISC-V processing nodes interconnected using a network interface attached to each processing node as well as a routing framework to negotiate communication between the nodes. This hardware layout is specifically employed for the purpose of simulating a spiking neural network, where each processing node is responsible for managing one or more neurons. The interconnectivity between nodes enables communication among neurons spanning across multiple nodes. Furthermore, the architecture adopts an event-driven messaging mechanism to effectively emulate the activity of the neurons.

As such, the primary objective of this research is to demon-
strate how a general purpose ISA such as RISC-V can be augmented to perform a highly-specialised task, namely the
simulation of spiking neural networks in a scalable and con-
figurable manner, whilst maintaining adherence to the original specifications of the ISA.

## Related works

### A. Spiking Neural Networks
An Artificial Neural Network (ANN) is a computing system
inspired by the biological neural networks that exist within the brain in order to solve complex tasks. An ANN is essentially a collection of artificial neurons connected together to form a network using links that imitate synapses in the brain A Spiking Neural Network (SNN) is a relatively new variety
of ANNs that more closely resembles actual biological neural
networks by incorporating the concept of time, with neurons
transmitting information during neuron spike events rather
than at each propagation cycle as is typically the case with
ANNs. Due to this inherent event-driven nature, SNNs of-
fer higher energy efficiency and a greater degree of parallelism in computations. However, it is the same event-driven nature that hinders the realisation of SNNs using general-purpose CPU and GPU hardware, and specialised hardware with native capabilities for simulating neuron spike events as well as hardware support for large-scale parallelism is required. 

This is the primary motivation for the development of neuromorphic architectures.
In the exploration of SNNs, various neuron models have
been developed, ranging from biologically plausible models
such as the Hodgkin-Huxley model to simplistic mod-
els such as the integrate-and-fire model. Biophysically
accurate models are prohibitively expensive in terms of the
computational power required and it is difficult to simulate
more than a handful of such neurons using currently available hardware. In contrast, simple models such as the integrate-
and-fire model are computationally efficient but they are too simple and not realistic enough to imitate the rich spiking
and bursting dynamics of natural neurons. Biologically-
inspired models such as the Izhikevich model and the
Fitzhugh-Nagumo model offer a compromise between
the two extremes wherein the model is complex enough to
sufficiently emulate the behaviour of natural neurons while
also being computationally effective.

## Methodology

## Experiment Setup and Implementation

## Results and Analysis

## Conclusion

## Publications
[//]: # "Note: Uncomment each once you uploaded the files to the repository"

<!-- 1. [Semester 7 report](./) -->
<!-- 2. [Semester 7 slides](./) -->
<!-- 3. [Semester 8 report](./) -->
<!-- 4. [Semester 8 slides](./) -->
<!-- 5. Author 1, Author 2 and Author 3 "Research paper title" (2021). [PDF](./). -->


## Links

[//]: # ( NOTE: EDIT THIS LINKS WITH YOUR REPO DETAILS )

- [Project Repository](https://github.com/cepdnaclk/e17-4yp-Neuromorphic-NoC-Architecture-for-SNNs)
- [Project Page](https://cepdnaclk.github.io/e17-4yp-Neuromorphic-NoC-Architecture-for-SNNs/)
- [Department of Computer Engineering](http://www.ce.pdn.ac.lk/)
- [University of Peradeniya](https://eng.pdn.ac.lk/)

[//]: # "Please refer this to learn more about Markdown syntax"
[//]: # "https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet"
