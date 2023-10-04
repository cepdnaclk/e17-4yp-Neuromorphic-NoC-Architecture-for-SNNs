import sys
import csv
import os
import shutil

# instruction sets grouped by the type
inst_data = {}

# arg types
argList = {'inp_file': '', 'out_file': ''}
# arg keywords
argKeys = {'-i': 'inp_file', '-o': 'out_file'}

# array to load the instructions
Instructions = []
# this dictionary is used to remember the position of the label
labelPosition = {}

# the instuction count the written to the file
inst_count = 0

FILE_SIZE = 1024

def format(numOfDigits, num):
    return str(num).zfill(numOfDigits)[:numOfDigits]

# instruction formatting structure
# loop through the instructions and do the nessary stuff
def formatInstructions(Instructions):
    index = 0
    for ins in Instructions:
        formatInstruction(ins, index)
        index += 1

# format the different types of instructions
def formatInstruction(ins, index):
    # final instruction
    finalIns = []
    tmp_split = ins.split()
    instruction_name = tmp_split.pop(0)
    finalIns.append(instruction_name.upper())
    # spliting by the ','
    for tmp in tmp_split:
        # splitting by comma
        tmp_split_2 = tmp.split(',')
        tmp_split_2 = list(filter(lambda a: a != '', tmp_split_2))

        # segmented list before putting together
        segmented_list = []

        for item in tmp_split_2:
            tmpItem = item
            # removing letter x 
            item = item.replace('x', '')
            # identifyng the sections with brackets
            if '(' and ')' in item:
                # removing ) from the string
                item = item.replace(')', '')
                tmp_split_3 = item.split('(')
                tmp_split_3.reverse()
                segmented_list.extend(tmp_split_3)
            # resolwing the labels into ofsets
            elif item.isalpha():
                # print("Testing", tmpItem, (labelPosition[tmpItem]-index-1)*4)
                segmented_list.append((labelPosition[tmpItem]-index-1)*4)
            else:
                segmented_list.append(item)

        finalIns.extend(segmented_list)

    #print(instruction_name, finalIns)
    handleInstruction(finalIns)

# read the csv and create the instruction data dictionary
def read_csv():
    # reading the csv file
    with open('RV32IM.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')

        for row in csv_reader:
            opcode = format(7, row[0])
            funct3 = format(3, row[1])
            funct7 = format(7, row[2])
            inst = row[3]
            _type = row[4]
            inst_data[inst] = {'opcode': opcode,
                               'funct3': funct3, 'funct7': funct7, 'type': _type}

# handling the separated instructions
def handleInstruction(separatedIns):
    Instruction = None
    space = '' # used to visualize the space in instruction in debug mode

    # handle R-Type instructions
    if(inst_data[separatedIns[0]]['type'] == "R-Type"):
        Instruction = inst_data[separatedIns[0]]['funct7'] + toBin(5, separatedIns[3]) + toBin(
            5, separatedIns[2]) + inst_data[separatedIns[0]]['funct3'] + toBin(5, separatedIns[1]) + inst_data[separatedIns[0]]['opcode']
        
    elif(inst_data[separatedIns[0]]['type'] == "I - Type "):
        if separatedIns[0][1] == "L":
            # lw rs2:value  immediate  rs1:base
            Instruction = toBin(12, separatedIns[2]) + space + toBin(5, separatedIns[3]) + space + inst_data[separatedIns[0]]['funct3'] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']

        Instruction = toBin(12, separatedIns[3]) + space + toBin(5, separatedIns[2]) + space + inst_data[separatedIns[0]]['funct3'] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']
        
        
    elif(inst_data[separatedIns[0]]['type'] == "S-Type"):
        # sw rs2:value  immediate  rs1:base
        immediate = toBin(12, separatedIns[2])
        Instruction = immediate[:7] + space + toBin(5, separatedIns[1]) + space + toBin(5, separatedIns[3])+ space + inst_data[separatedIns[0]]['funct3']+ space + immediate[7:] + space + inst_data[separatedIns[0]]['opcode']
    
    elif(inst_data[separatedIns[0]]['type'] == "B-Type"):
        # beq rs1, rs2, label
        immediate = toBin(13, separatedIns[3])
        Instruction = immediate[0]+ space + immediate[2:8] + space + toBin(5, separatedIns[2])+ space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['funct3'] + space + immediate[8:12] + space + immediate[1] + space + inst_data[separatedIns[0]]['opcode'] 
    
    elif(inst_data[separatedIns[0]]['type'] == "U -Type"):
        # lui rd, immediate
        immediate = toBin(32, separatedIns[2])
        Instruction = immediate[0:20] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']

    elif(inst_data[separatedIns[0]]['type'] == "J-Type"):
        #jal rd, immediate
        immediate = toBin(21, separatedIns[2])
        Instruction = immediate[0] + space + immediate[10:20]+ space +immediate[9] + space + immediate[1:9] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']
        print(immediate, Instruction)

    # elif(inst_data[separatedIns[0]]['type'] == "NOP-type"):
    #     Instruction = "0"*32
    # FLOATING 
    # LWNET ,SWNET
    # EBREAK, ECALL , FENCE
    # call, tail


    print(separatedIns[0],separatedIns, Instruction, hex(int(Instruction, 2)))
    saveToFile(Instruction)

# taking the file name if passed as an argument
def handleArgs():
    n = len(sys.argv)
    for i in range(1, n):
        if (sys.argv[i].strip() in argKeys):
            argList[argKeys[sys.argv[i]]] = sys.argv[i+1]


# opening the assemblyfile and reading through the file
def handleInpFile():
    global labelPosition

    if argList['inp_file'] == '':
        print('Input file not found')
        sys.exit(1)

    # opening the assembly file
    f = open(argList['inp_file'], "r")

    tmp_ins = []
    for ins in f:
        ins = pseudo_ins(ins)
        tmp_ins.extend(ins)

    f.close()
    print(tmp_ins)

    
    # line count for the instructions
    lineCount = 0
    # loop through the file and handle the instrctions separately
    for ins in tmp_ins:
        # skipping enpty lines
        if ins.strip() == '':
            continue
        # skiping the comments
        elif ins.strip()[0] == ';':
            continue
        elif ins.strip()[-1] == ':':
            labelPosition[ins.strip()[:(len(ins.strip())-1)]] = lineCount
        else:
            Instructions.append(ins)
            lineCount += 1
        # handleInstruction(ins)

    # start the instruction formatting
    formatInstructions(Instructions)

# convert a given number to binary according to a given format
def toBin(numOfDigits, num):
    num = int(num)
    s = bin(num & int("1"*numOfDigits, 2))[2:]
    return ("{0:0>%s}" % (numOfDigits)).format(s)

# saving data to a .bin file
def saveToFile(line):
    global inst_count
    file = "build/"+ argList['inp_file'].split('.')[0] + '.bin'
    if not (argList['out_file'] == ''):
        file = "build/" + argList['out_file']
    # saving the new line to the output file
    f = open(file, "a")
    for i in range(3, -1, -1):
        f.write(line[(i*8):(i*8+8)] + "\n")
    f.close()
    inst_count = inst_count + 1

# fillig the rest of the file 
def fillTheFile():
    global FILE_SIZE
    file = "build/" + argList['inp_file'].split('.')[0] + '.bin'
    if not (argList['out_file'] == ''):
        file = "build/" + argList['out_file']

    f = open(file, "a")
    for i in range(FILE_SIZE - (4*inst_count)):
        f.write('x'*8 + '\n')

    # # copy the bin file to the verilog folder
    # shutil.copy2(file, )

def pseudo_ins(ins):
    # convert to isa ins
    ins = ins.split()

    

    if ins[0] == 'nop':
        ins[0] = 'addi'
        ins.extend(["x0","x0","0"])
    if ins[0] == 'li':
        ins[0] = 'addi'
        tmp = ins[2]
        ins[2] = "x0"
        ins.append(tmp)
    elif ins[0] == 'mv':
        ins[0] = 'addi'
        ins.append("0")
    elif ins[0] == 'not':
        ins[0] = 'xori'
        ins.append("-1")
    elif ins[0] == 'neg':
        ins[0] = 'sub'
        ins.append(ins[2])
        ins[1] = 'x0'
    elif ins[0] == 'negw':
        # w?
        ins[0] = 'subw'
        ins.append("-1")
        ins[2] = "x0"
    elif ins[0] == 'sext.w':
        # w?
        ins[0] = 'addiw'
        ins.append("0")
    elif ins[0] == 'seqz':
        ins[0] = 'sltiu'
        ins.append("1")
    elif ins[0] == 'snez':
        ins[0] = 'sltu'
        ins.append(ins[2])
        ins[2] = "x0"
    elif ins[0] == 'sltz':
        ins[0] = 'slt'
        ins.append("x0")
    elif ins[0] == 'sgtz':
        ins[0] = 'slt'
        ins.append(ins[2])
        ins[2] = "x0"


    elif ins[0] == 'beqz':
        ins[0] = 'beq'
        ins.append(ins[2])
        ins[2] = "x0"
    elif ins[0] == 'bneq':
        ins[0] = 'bne'
        ins.append(ins[2])
        ins[2] = "x0"
    elif ins[0] == 'blez':
        ins[0] = 'bge'
        ins.append(ins[2])
        ins[2] = ins[1] 
        ins[1] = "x0"
    elif ins[0] == 'bgez':
        ins[0] = 'bge'
        ins.append(ins[2])
        ins[2] = "x0"
    elif ins[0] == 'bltz':
        ins[0] = 'blt'
        ins.append(ins[2])
        ins[2] = "x0"
    elif ins[0] == 'bgtz':
        ins[0] = 'blt'
        ins.append(ins[2])
        ins[2] = ins[1] 
        ins[1] = "x0"

    elif ins[0] == 'bgt':
        ins[0] = 'blt'
        tmp = ins[1]
        ins[1] = ins[2]
        ins[2] = tmp
    elif ins[0] == 'ble':
        ins[0] = 'bge'
        tmp = ins[1]
        ins[1] = ins[2]
        ins[2] = tmp
    elif ins[0] == 'bgtu':
        ins[0] = 'bltu'
        tmp = ins[1]
        ins[1] = ins[2]
        ins[2] = tmp
    elif ins[0] == 'bleu':
        ins[0] = 'bgeu'
        tmp = ins[1]
        ins[1] = ins[2]
        ins[2] = tmp


    elif ins[0] == 'j':
        ins[0] = 'jal'
        ins.append(ins[1])
        ins[1] = "x0"
    elif ins[0] == 'jal':
        ins.append(ins[1])
        ins[1] = "x1"
    elif ins[0] == 'jr':
        ins[0] = 'jalr'
        ins.extend(["0",ins[1]])
        ins[1] = "x0"
    elif ins[0] == 'jalr':
        ins.extend(["0",ins[1]])
        ins[1] = "x1"
    elif ins[0] == 'ret':
        ins[0] = 'jalr'
        ins.extend(["x0","0","x1"])

    # test call and tail 
    # str cat or num add offset?
    elif ins[0] == 'call':
        offset = toBin(32,int(ins[1]))
        ins = ["auipc","x1",str(offset)[:20] + str(offset)[20]]
        ins2 = ["jalr","x1",str(offset)[20:],"x1"]
        return [ins,ins2]
    elif ins[0] == 'tail':
        offset = toBin(32,int(ins[1]))
        ins = ["auipc","x6",str(offset)[:20] + str(offset)[20]]
        ins2 = ["jalr","x0",str(offset)[20:],"x6"]
        return [ins,ins2]

#fence
# EBREAK, ECALL

    ins = ' '.join(ins)
    print(ins)
    return [ins] 
    
# if __name__ == "__main__":
#     # remove all .bin file in the directory
#     for i in os.listdir("../build"):
#         if i.endswith(".bin"):
#             os.remove("../build/" + i)

#     #create the instruction disctionary
#     read_csv()
#     # handdle the argments
#     handleArgs()
#     # input file reding sequence
#     handleInpFile()
#     print(labelPosition)
#     # fill the rest of the bin file
#     fillTheFile()

    