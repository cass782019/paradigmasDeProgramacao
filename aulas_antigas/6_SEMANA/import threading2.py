import threading
import time

# Recursos compartilhados
lock1 = threading.Lock()
lock2 = threading.Lock()

def try_lock_example(thread_name):
    while True:
        print(f"{thread_name} tentando adquirir lock1")
        acquired_lock1 = lock1.acquire(timeout=0.1)
        if acquired_lock1:
            print(f"{thread_name} adquiriu lock1")
            try:
                print(f"{thread_name} tentando adquirir lock2")
                acquired_lock2 = lock2.acquire(timeout=0.1)
                if acquired_lock2:
                    print(f"{thread_name} adquiriu lock2")
                    # Realiza o trabalho com ambos os recursos adquiridos
                    print(f"{thread_name} está realizando trabalho com ambos os locks")
                    time.sleep(0.2)  # Simula trabalho
                    print(f"{thread_name} liberando lock2")
                    lock2.release()
                    print(f"{thread_name} liberando lock1")
                    lock1.release()
                    break:
                else:
                    print(f"{thread_name} não conseguiu adquirir lock2, liberando lock1")
                    lock1.release()
            except Exception as e:
                print(f"{thread_name} encontrou um erro: {e}")
                lock1.release()
        time.sleep(0.1)  # Espera um pouco antes de tentar novamente

# Criação das threads
t1 = threading.Thread(target=try_lock_example, args=("Thread 1",))
t2 = threading.Thread(target=try_lock_example, args=("Thread 2",))

# Início das threads
t1.start()
t2.start()

# Espera pela conclusão das threads
t1.join()
t2.join()

print("Execução concluída")
