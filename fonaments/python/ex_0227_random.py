frase = input("Escriu una frase: ")

frase_neta = ""
for char in frase:
    if char.isalpha() or char.isnumeric() or char == " ":
        frase_neta = frase_neta + char

print(frase_neta)

# Llista de paraules
paraules = frase_neta.split()
print(paraules)

# Diccionari amb comptador de paraules
dicc_comptador = {}

for paraula in paraules:
    comptador = 0
    for paraula_aux in paraules:
        if paraula == paraula_aux:
            comptador += 1
    
    dicc_comptador[paraula] = comptador

print(dicc_comptador)

