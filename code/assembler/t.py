
def format(numOfDigits, num):
    return str(num).zfill(numOfDigits)[:numOfDigits]

def toBin(numOfDigits, num):
    return format(numOfDigits, "{0:b}".format(int(num)))


print(bin(-1))