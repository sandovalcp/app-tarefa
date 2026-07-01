<%@ page import="java.util.List" %>
<%@ page import="com.exemplo.todo.Task" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Tomcat + Java 8 - Lista Tarefa</title>
    <style>
        body {
            background-color: #1e1e24;
            color: #f5f5f7;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            background-color: #2a2a35;
            padding: 2rem;
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.3);
            width: 400px;
        }
        h1 {
            font-size: 1.5rem;
            margin-top: 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .badge {
            background-color: #d85a03;
            color: #fff;
            font-size: 0.8rem;
            padding: 4px 12px;
            border-radius: 12px;
        }
        .subtitle {
            color: #8a8a9e;
            font-size: 0.85rem;
            margin-bottom: 1.5rem;
        }
        .form-group {
            display: flex;
            gap: 10px;
            margin-bottom: 1.5rem;
        }
        input[type="text"] {
            flex: 1;
            background-color: #1e1e24;
            border: 1px solid #444454;
            border-radius: 8px;
            padding: 10px;
            color: #fff;
            font-size: 0.9rem;
        }
        input[type="text"]:focus {
            outline: none;
            border-color: #d85a03;
        }
        button.btn-add {
            background-color: #d85a03;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: bold;
            cursor: pointer;
        }
        button.btn-add:hover {
            background-color: #f76c02;
        }
        ul {
            list-style: none;
            padding: 0;
            margin: 0;
            max-height: 250px;
            overflow-y: auto;
        }
        li {
            background-color: #21212b;
            border: 1px solid #3a3a4a;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.95rem;
        }
        button.btn-del {
            box-shadow: none;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }
    </style>
</head>
<body>

<div class="container">
    <%
        List<Task> tasks = (List<Task>) request.getAttribute("tasks");
        int totalItens = (tasks != null) ? tasks.size() : 0;
    %>
    <h1>
        Tomcat + Java 8 - Lista Tarefa
        <span class="badge"><%= totalItens %> <%= (totalItens == 1) ? "item" : "itens" %></span>
    </h1>
    <!-- <div class="subtitle">Executando de forma agnóstica (Podman/OKE)</div> -->

    <form action="tasks" method="post" class="form-group">
        <input type="hidden" name="action" value="add"/>
        <input type="text" name="descricao" placeholder="Nova tarefa no Tomcat..." required autocomplete="off"/>
        <button type="submit" class="btn-add">Adicionar</button>
    </form>

    <ul>
    <%
        if (tasks != null && !tasks.isEmpty()) {
            for (Task t : tasks) {
    %>
        <li>
            <span><%= t.getDescricao() %></span>
            <form action="tasks" method="post" style="margin: 0;">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="<%= t.getId() %>"/>
                <button type="submit" class="btn-del">❌</button>
            </form>
        </li>
    <%
            }
        } else {
    %>
        <div style="text-align: center; color: #8a8a9e; font-size: 0.9rem; padding: 1rem;">
            Nenhuma tarefa cadastrada.
        </div>
    <%
        }
    %>
    </ul>
</div>

</body>
</html>