import threading

counter = 0  # Variável compartilhada

def increment():
    global counter
    for _ in range(100000):
        counter += 1

# Criação das threads
thread1 = threading.Thread(target=increment)
thread2 = threading.Thread(target=increment)

# Início das threads
thread1.start()
thread2.start()

# Espera pela conclusão das threads
thread1.join()
thread2.join()

print("Valor final do counter:", counter)
