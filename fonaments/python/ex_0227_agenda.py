"""Objectiu
Crear un programa que gestioni una agenda de contactes utilitzant un diccionari de Python.

Heu de crear una agenda digital que permeti emmagatzemar contactes amb els seus números de telèfon. 
El programa ha de permetre afegir, veure, buscar i eliminar contactes."""

# Requisits tècnics
# Utilitzar un diccionari per emmagatzemar els contactes

contactes = {}

# Implementar les següents funcions:
# afegir_contacte() - Afegeix un nou contacte
# veure_contactes() - Mostra tots els contactes
# buscar_telefon() - Cerca el telèfon d'un contacte
# eliminar_contacte() - Elimina un contacte
# mostrar_menu() - Mostra el menú d'opcions

# Funcionalitats específiques
# 1. Afegir contacte
# Demana el nom del contacte
# Demana el número de telèfon
# Afegeix el contacte al diccionari
# Mostra el diccionari actualitzat

def afegir_contacte():
    nom = input("Nom? ")
    telf = input("Telèfon? ")
    contactes[nom] = telf
    
    print(contactes)

# afegir_contacte()

# 2. Veure tots els contactes
# Mostra tots els contactes guardats
# Format: "El nom és [nom] i el telèfon és el [telèfon]"

def veure_contactes():
    print("")

    if len(contactes) == 0:
        print("No hi ha contactes.")

    for key, value in contactes.items():
        print("El telèfon de [" + key + "] és [" + value + "]")

# veure_contactes()

# 3. Buscar telèfon
# Demana un nom per buscar
# Si el nom existeix, mostra el seu telèfon
# Si no existeix, mostra un missatge d'error

def buscar_telefon():
    print("")
    nom = input("Quin contacte busques? ")
    
    if nom in contactes:
        print("El telèfon de " + nom + "és " + contactes[nom])
    else:
        print("No s'ha trobat el contacte.")

# buscar_telefon()

# 4. Eliminar contacte
# Demana el nom del contacte a eliminar
# Si existeix, l'elimina del diccionari
# Si no existeix, mostra un missatge d'error

def eliminar_contacte():
    print("")
    nom = input("Quin contacte vols eliminar? ")
    
    if nom in contactes:
        del contactes[nom]
    else:
        print("No s'ha trobat el contacte.")
    
    print(contactes)

# eliminar_contacte()

# mostrar_menu() - Mostra el menú d'opcions

def mostrar_menu():
    print("")
    print("1. Afegir Contacte")
    print("2. Veure Contactes")
    print("3. Buscar Telèfon")
    print("4. Eliminar Contacte")
    print("0. Sortir")

# mostrar_menu()

while True:
    mostrar_menu()
    print("")
    opcio = int(input("Tria una opció (0-5): "))

    if opcio == 0: break
    elif opcio == 1: afegir_contacte()
    elif opcio == 2: veure_contactes()
    elif opcio == 3: buscar_telefon()
    elif opcio == 4: eliminar_contacte()
    else: print("Opció no vàlida. Tria una altra (0-5)")

