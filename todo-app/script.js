// Todo App Class for Managing Todos
class TodoApp {
    constructor() {
        this.todos = [];
        this.currentFilter = 'all';
        this.editingId = null;
        this.STORAGE_KEY = 'cediapp_todos';
        this.init();
    }

    init() {
        this.loadFromStorage();
        this.setupEventListeners();
        this.render();
    }

    setupEventListeners() {
        // Add todo
        document.getElementById('addBtn').addEventListener('click', () => this.addTodo());
        document.getElementById('todoInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addTodo();
        });

        // Filter
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
                this.currentFilter = e.target.dataset.filter;
                this.render();
            });
        });

        // Action buttons
        document.getElementById('clearCompletedBtn').addEventListener('click', () => this.clearCompleted());
        document.getElementById('clearAllBtn').addEventListener('click', () => this.clearAll());
        document.getElementById('exportBtn').addEventListener('click', () => this.exportTodos());
        document.getElementById('importBtn').addEventListener('click', () => {
            document.getElementById('importFile').click();
        });

        // Import file
        document.getElementById('importFile').addEventListener('change', (e) => this.importTodos(e));
    }

    addTodo() {
        const input = document.getElementById('todoInput');
        const text = input.value.trim();

        if (text === '') {
            alert('Please enter a task!');
            return;
        }

        const todo = {
            id: Date.now(),
            text: text,
            completed: false,
            createdAt: new Date().toLocaleString(),
            priority: 'medium',
            dueDate: ''
        };

        this.todos.push(todo);
        input.value = '';
        input.focus();
        this.saveToStorage();
        this.render();
    }

    deleteTodo(id) {
        if (confirm('Are you sure you want to delete this task?')) {
            this.todos = this.todos.filter(todo => todo.id !== id);
            this.saveToStorage();
            this.render();
        }
    }

    toggleTodo(id) {
        const todo = this.todos.find(t => t.id === id);
        if (todo) {
            todo.completed = !todo.completed;
            this.saveToStorage();
            this.render();
        }
    }

    editTodo(id) {
        this.editingId = id;
        const todo = this.todos.find(t => t.id === id);
        if (todo) {
            this.showEditModal(todo);
        }
    }

    showEditModal(todo) {
        const modal = document.createElement('div');
        modal.className = 'modal show';
        modal.innerHTML = `
            <div class="modal-content">
                <h2>Edit Task</h2>
                <form id="editForm">
                    <div class="form-group">
                        <label for="editText">Task:</label>
                        <input type="text" id="editText" value="${this.escapeHtml(todo.text)}" required>
                    </div>
                    <div class="form-group">
                        <label for="editPriority">Priority:</label>
                        <select id="editPriority">
                            <option value="low" ${todo.priority === 'low' ? 'selected' : ''}>Low</option>
                            <option value="medium" ${todo.priority === 'medium' ? 'selected' : ''}>Medium</option>
                            <option value="high" ${todo.priority === 'high' ? 'selected' : ''}>High</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="editDueDate">Due Date:</label>
                        <input type="date" id="editDueDate" value="${todo.dueDate}">
                    </div>
                    <div class="modal-buttons">
                        <button type="submit" class="modal-btn save-btn">Save</button>
                        <button type="button" class="modal-btn cancel-btn">Cancel</button>
                    </div>
                </form>
            </div>
        `;

        document.body.appendChild(modal);

        const form = modal.querySelector('#editForm');
        const cancelBtn = modal.querySelector('.cancel-btn');

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const updatedTodo = this.todos.find(t => t.id === this.editingId);
            if (updatedTodo) {
                updatedTodo.text = document.getElementById('editText').value;
                updatedTodo.priority = document.getElementById('editPriority').value;
                updatedTodo.dueDate = document.getElementById('editDueDate').value;
                this.saveToStorage();
                this.render();
            }
            modal.remove();
        });

        cancelBtn.addEventListener('click', () => {
            modal.remove();
        });

        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });
    }

    clearCompleted() {
        if (confirm('Are you sure you want to clear all completed tasks?')) {
            this.todos = this.todos.filter(todo => !todo.completed);
            this.saveToStorage();
            this.render();
        }
    }

    clearAll() {
        if (confirm('Are you sure you want to delete ALL tasks? This cannot be undone!')) {
            this.todos = [];
            this.saveToStorage();
            this.render();
        }
    }

    exportTodos() {
        const data = {
            todos: this.todos,
            exportDate: new Date().toLocaleString(),
            totalTasks: this.todos.length,
            completedTasks: this.todos.filter(t => t.completed).length
        };

        const dataStr = JSON.stringify(data, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        const url = URL.createObjectURL(dataBlob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `todos_${new Date().getTime()}.json`;
        link.click();
        URL.revokeObjectURL(url);
    }

    importTodos(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const data = JSON.parse(e.target.result);
                if (confirm(`Import ${data.todos.length} tasks? This will add to existing tasks.`)) {
                    this.todos = [...this.todos, ...data.todos];
                    this.saveToStorage();
                    this.render();
                    alert('Tasks imported successfully!');
                }
            } catch (error) {
                alert('Error importing file. Please check the file format.');
            }
        };
        reader.readAsText(file);
    }

    getFilteredTodos() {
        switch (this.currentFilter) {
            case 'active':
                return this.todos.filter(todo => !todo.completed);
            case 'completed':
                return this.todos.filter(todo => todo.completed);
            default:
                return this.todos;
        }
    }

    updateStats() {
        const total = this.todos.length;
        const completed = this.todos.filter(t => t.completed).length;
        const remaining = total - completed;

        document.getElementById('totalTasks').textContent = total;
        document.getElementById('completedTasks').textContent = completed;
        document.getElementById('remainingTasks').textContent = remaining;
    }

    render() {
        const todoList = document.getElementById('todoList');
        const emptyState = document.getElementById('emptyState');
        const filteredTodos = this.getFilteredTodos();

        todoList.innerHTML = '';

        if (filteredTodos.length === 0) {
            emptyState.classList.add('show');
            todoList.style.display = 'none';
        } else {
            emptyState.classList.remove('show');
            todoList.style.display = 'block';

            filteredTodos.forEach(todo => {
                const li = document.createElement('li');
                li.className = `todo-item ${todo.completed ? 'completed' : ''}`;
                
                const priorityClass = `priority-${todo.priority}`;
                const priorityText = todo.priority.charAt(0).toUpperCase() + todo.priority.slice(1);

                li.innerHTML = `
                    <input type="checkbox" class="checkbox" ${todo.completed ? 'checked' : ''}>
                    <span class="todo-text">${this.escapeHtml(todo.text)}</span>
                    ${todo.dueDate ? `<span class="todo-date">📅 ${todo.dueDate}</span>` : ''}
                    <span class="priority-badge ${priorityClass}">${priorityText}</span>
                    <button class="edit-btn">Edit</button>
                    <button class="delete-btn-item">Delete</button>
                `;

                const checkbox = li.querySelector('.checkbox');
                checkbox.addEventListener('change', () => this.toggleTodo(todo.id));

                const editBtn = li.querySelector('.edit-btn');
                editBtn.addEventListener('click', () => this.editTodo(todo.id));

                const deleteBtn = li.querySelector('.delete-btn-item');
                deleteBtn.addEventListener('click', () => this.deleteTodo(todo.id));

                todoList.appendChild(li);
            });
        }

        this.updateStats();
    }

    saveToStorage() {
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.todos));
    }

    loadFromStorage() {
        const stored = localStorage.getItem(this.STORAGE_KEY);
        this.todos = stored ? JSON.parse(stored) : [];
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new TodoApp();
});
