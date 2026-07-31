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