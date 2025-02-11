import 'dart:collection';
import 'dart:core';

class FixedSizeFIFOQueue<T> {

    Queue<T> queue = Queue<T>();

    int capacity = 0;

    // Constructor to set the fixed size capacity
    FixedSizeFIFOQueue({required this.capacity}) {
      if (capacity <= 0) {
          throw Exception("Capacity must be greater than zero");
      }
      this.capacity = capacity;
    }

    bool contains(T obj) {
      return queue.contains(obj);
    }

    void enqueueAll(Iterable<T> elems) {
        queue.addAll(elems);
    }

    // Insert an element at the front of the queue
    void enqueue(T element) {
      // If the element already exists in the queue, remove it and move it to the front
      if (queue.contains(element)) {
          queue.remove(element);  // Remove the element from its current position
      } else if (queue.length == capacity) {
          // If the queue is full, remove the oldest element (from the back)
          queue.remove(queue.last);
      }

      // Add the element to the front of the queue
      queue.addFirst(element);
    }

    // Remove an element from the back of the queue
    T dequeue() {
      if (isEmpty()) {
          throw Exception("Queue is empty");
      }

      T last = queue.last;
      queue.remove(queue.last);
      return last;
    }

    // Remove an element from the back of the queue
    void dequeueElement(T t) {
      if (isEmpty()) {
          throw Exception("Queue is empty");
      }
      queue.remove(t);
    }

    // Check if the queue is empty
    bool isEmpty() {
      return queue.isEmpty;
    }

    // Peek the element at the back of the queue (without removing it)
    T peek() {
      if (isEmpty()) {
          throw Exception("Queue is empty");
      }
      return queue.last;
    }

    // Get the size of the queue
    int size() {
      return queue.length;
    }

    // Get the capacity of the queue
    int getCapacity() {
      return capacity;
    }

    Iterable<T> getElements() {
      return queue;
    }

    Iterator<T> iterator() {
      return queue.iterator;
    }
}