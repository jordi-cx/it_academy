"""Objectiu
Crear un programa que gestioni les notes d'una classe utilitzant funcions. El programa ha de permetre 
afegir notes, veure-les, calcular la mitjana i trobar la nota més alta."""

# Funcions a implementar:
# mostrar_menu() - Mostra un menú amb 5 opcions
# afegir_nota() - Demana una nota per teclat i l'afegeix a la llista
# veure_notes() - Mostra totes les notes de la llista
# calcular_mitjana() - Calcula i mostra la mitjana de totes les notes
# trobar_maxima() - Troba i mostra la nota més alta

# Comportament esperat:
# El programa comença amb una llista buida de notes
# Mostra el menú i espera que l'usuari trii una opció (0-4)
# Es repeteix fins que l'usuari tria l'opció 0 (Sortir)
# Cada opció crida la funció corresponent

notes = []

def mostrar_menu():
    print("\n1. Afegir Nota\n2. Veure Notes\n3. Nota mitjana\n4. Nota màxima\n0. Sortir")

def veure_notes():
    print("Aquestes són totes les notes:")
    print(notes, sep=", ")

def afegir_nota():
    nota = float(input("Afegeix la nota: "))
    notes.append(nota)
    veure_notes()

def calcular_mitjana():
    mitjana = sum(notes) / len(notes)
    print("Aquesta és la nota mitjana: ", mitjana)

def trobar_maxima():
    maxima = max(notes)
    print("Aquesta és la nota màxima: ", maxima)

while True:
    mostrar_menu()
    opcio = int(input("Tria una opció: "))

    if opcio == 0:
        break
    elif opcio == 1:
        afegir_nota()
    elif opcio == 2:
        veure_notes()
    elif opcio == 3:
        calcular_mitjana()
    elif opcio == 4:
        trobar_maxima()
    else:
        print("Has de triar una opció (0-4)")

