valor = int(input())

valor_notas = [100, 50, 20, 10, 5, 2, 1]

print(valor)


for nota in valor_notas:
    quantidade = valor // nota
    valor = valor % nota
    nota = str(nota) + ",00"
    
    print(f"{quantidade} nota(s) de R$ {(nota)}")

