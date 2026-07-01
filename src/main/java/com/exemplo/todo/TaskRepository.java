package com.exemplo.todo;

import java.util.ArrayList;
import java.util.List;

// Import explícito para garantir a vinculação do modelo pelo compilador Maven
import com.exemplo.todo.Task;

public class TaskRepository {

    private static final List<Task> tasks = new ArrayList<>();
    private static int counter = 1;

    public static List<Task> listar() {
        return tasks;
    }

    public static synchronized void adicionar(String descricao) {
        tasks.add(new Task(counter++, descricao));
    }

    public static synchronized void remover(int id) {
        tasks.removeIf(t -> t.getId() == id);
    }
}