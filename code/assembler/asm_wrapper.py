from assembler import *
import os

if __name__ == "__main__":
    # remove all .bin file in the directory
    for i in os.listdir("build"):
        if i.endswith(".bin"):
            os.remove("build/" + i)

    #create the instruction disctionary
    read_csv()
    # handdle the argments
    handleArgs()
    # input file reding sequence
    handleInpFile()
    print(labelPosition)
    # fill the rest of the bin file
    fillTheFile()
