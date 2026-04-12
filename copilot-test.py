#write a function to calculate prime numbers betweeen two given numbers
def prime_numbers(start, end):
    primes = []
    for num in range(start, end + 1):
        if num > 1:
            for i in range(2, int(num**0.5) + 1):
                if (num % i) == 0:
                    break
            else:
                primes.append(num)
    return primes
#write code to input the two numbers and call the function
start = int(input("Enter the start number: "))
end = int(input("Enter the end number: "))
print(f"Prime numbers between {start} and {end} are: {prime_numbers(start, end)}")
#test the function
