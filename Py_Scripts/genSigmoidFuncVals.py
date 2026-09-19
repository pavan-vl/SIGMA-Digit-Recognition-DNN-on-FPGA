import math

def genSigContent(dataWidth, sigmoidSize, weightIntWidth, inputIntWidth, filename):
    f = open(filename, "w")
    fractBits = sigmoidSize - (weightIntWidth + inputIntWidth)
    if fractBits < 0: #Sigmoid size is smaller the integer part of the MAC operation
        fractBits = 0
    x = -2**(weightIntWidth+inputIntWidth-1) #Smallest input going to the Sigmoid LUT from the neuron
    for i in range(0, 2**sigmoidSize):
        y = sigmoid(x)
        z = DtoB(y, dataWidth, dataWidth-inputIntWidth)
        f.write(z+'\n')
        x = x+(2**-fractBits)
    f.close()

def DtoB(num, dataWidth, fracBits): #function for converting into two's complement format, zero-padded to dataWidth bits
    if num >= 0:
        num = num * (2**fracBits)
        num = int(num)
        e = format(num, '0{}b'.format(dataWidth))
    else:
        num = -num
        num = num * (2**fracBits) #number of fractional bits
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2**dataWidth - num
        e = format(d, '0{}b'.format(dataWidth))
    return e

def sigmoid(x):
    try:
        return 1 / (1+math.exp(-x)) #for x less than -1023 will give value error
    except:
        return 0

if __name__ == "__main__":
    # weightIntWidth=4 matches the tutorial video's default and matches your
    # existing working SigmoidFuncVals.mif (confirmed by both starting the
    # table with a run of all-zero entries -- see the -16 starting point below).
    # This does NOT match `weight_integer_Width_L1..4` (=1) in your includes.v --
    # worth reconciling that separately, since weightIntWidth also feeds
    # Relu_Function_Mod's output formatting.
    genSigContent(dataWidth=16, sigmoidSize=5,  weightIntWidth=4, inputIntWidth=1, filename="SigmoidFuncVals_5.mif")
    genSigContent(dataWidth=16, sigmoidSize=10, weightIntWidth=4, inputIntWidth=1, filename="SigmoidFuncVals_10.mif")
    genSigContent(dataWidth=16, sigmoidSize=8, weightIntWidth=4, inputIntWidth=1, filename="SigmoidFuncVals_8.mif")
