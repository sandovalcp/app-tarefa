package com.exemplo.todo;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// O Servlet agora responde na raiz do contexto e no subcaminho das ações
@WebServlet(urlPatterns = {"", "/tasks"})
public class TaskServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Popula sempre os atributos vindos do repositório em memória
        req.setAttribute("tasks", TaskRepository.listar());
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            String descricao = req.getParameter("descricao");
            if (descricao != null && !descricao.trim().isEmpty()) {
                TaskRepository.adicionar(descricao.trim());
            }
        }

        if ("delete".equals(action)) {
            String idParam = req.getParameter("id");
            if (idParam != null) {
                try {
                    int id = Integer.parseInt(idParam);
                    TaskRepository.remover(id);
                } catch (NumberFormatException e) {
                    // Ignora IDs malformados para manter a resiliência do fluxo
                }
            }
        }

        // REDIRECIONAMENTO INTELIGENTE:
        // Se vier do Ingress, respeita a URL externa contida no Referer;
        // caso contrário, redireciona de forma agnóstica para a raiz local.
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }
}