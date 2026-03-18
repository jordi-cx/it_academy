"""Objectiu
Crear un programa senzill que permeti gestionar una llista d'alumnes mitjançant un menú interactiu.

Requisits
Utilitzar una llista per emmagatzemar els noms dels alumnes
Implementar un menú amb 4 opcions
Permetre afegir, mostrar i eliminar alumnes"""

# Llista Inicial
# El programa ha de començar amb 2 alumnes a la llista

# Funcionalitats a Implementar
# Opció 1: Donar d'alta un alumne
# Demanar el nom del nou alumne
# Afegir-lo a la llista
# Mostrar missatge de confirmació
# Mostrar la llista actualitzada

# Opció 2: Mostrar tots els alumnes
# Llistar tots els alumnes (un per línia)

# Opció 3: Eliminar un alumne per posició
# Mostrar la llista actual d'alumnes
# Demanar la posició (número) de l'alumne a eliminar
# Eliminar l'alumne de la llista
# Mostrar missatge de confirmació
# Mostrar la llista actualitzada

# Opció 0: Sortir
# Ordena la llista de manera alfabètica
# Sortir del programa mostrant un missatge de comiat

alumnes = ["Jordi", "Anna"]

while True:
    print("Opció 1: Donar d'alta un alumne")
    print("Opció 2: Mostrar tots els alumnes")
    print("Opció 3: Eliminar un alumne per posició")
    print("Opció 0: Sortir")

    opcio = int(input("Tria una opció: "))

    if opcio == 1:
        nou_alumne = input("Nom de l'alumne a inscriure: ")
        alumnes.append(nou_alumne)
        print("T'has inscrit, " + nou_alumne)
        print("Alumens inscrits:")

        for i in range(len(alumnes)):
            print(i, ".", alumnes[i])

    elif opcio == 2:
        print("Alumens inscrits:")
        for i in range(len(alumnes)):
            print(i, ".", alumnes[i])

    elif opcio == 3:
        for i in range(len(alumnes)):
            print(i + 1, ".", alumnes[i])
        antic_alumne = int(input("Quin alumne vols eliminar? "))
        del alumnes[antic_alumne - 1]

        print("Alumne eliminat!\nLlista actualitzada d'alumnes:")
        for alumne in alumnes:
            print(alumne)

    elif opcio == 0:
        alumnes.sort()
        print("\nAlumens inscrits:")
        for alumne in alumnes:
            print(alumne)
        print("\nGràcies, fins una altra!")
        break

    else:
        print("Opció no vàlida :-(")

