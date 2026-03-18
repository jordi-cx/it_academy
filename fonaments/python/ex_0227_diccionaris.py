# diccionari = {}

""""
diccionari = { "Jordi": 50, "Alicia": 37, 0: 0.0 }

print(diccionari)
print(diccionari.keys())
print(diccionari.values())
print(diccionari.items())

for key in diccionari:
    print(key, "->", diccionari[key])

for key, value in diccionari.items():
    print(key, "->", value)
"""

diccionari = { "Jordi": 1975, "Alicia": 1989, "Anna": 1973 }
print(diccionari)

for key in sorted(diccionari.keys()):
    print(key, "->", diccionari[key])

for value in sorted(diccionari.values()):
    print(value)

print(help(diccionari))
