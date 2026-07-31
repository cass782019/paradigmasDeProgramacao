import threading

# Recursos compartilhados
lock1 = threading.Lock()
lock2 = threading.Lock()

def try_lock_example():
    while True:
        acquired_lock1 = lock1.acquire(timeout=0.1)
        acquired_lock2 = lock2.acquire(timeout=0.1)
        
        if acquired_lock1 and acquired_lock2:
            print("Locks adquiridos sem deadlock")
            lock1.release()
            lock2.release()
            break
        if acquired_lock1:
            lock1.release()
        if acquired_lock2:
            lock2.release()
# Criação das threads
t1 = threading.Thread(target=thread1)
t2 = threading.Thread(target=thread2)

# Início das threads
t1.start()
t2.start()

# Espera pela conclusão das threads
t1.join()
t2.join()
