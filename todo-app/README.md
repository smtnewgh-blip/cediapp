# Todo List Application

A fully functional, feature-rich Todo List application with local storage functionality. Built with vanilla JavaScript, HTML, and CSS.

## 🌟 Features

### Core Functionality
- ✅ **Add Tasks** - Easily add new tasks to your list
- ✅ **Mark Complete** - Check off completed tasks
- ✅ **Edit Tasks** - Modify task details including text, priority, and due date
- ✅ **Delete Tasks** - Remove individual tasks
- ✅ **Local Storage** - All tasks are saved automatically to browser storage

### Advanced Features
- 📊 **Real-time Statistics** - View total, completed, and remaining tasks
- 🎯 **Priority Levels** - Assign High, Medium, or Low priority to tasks
- 📅 **Due Dates** - Set and track due dates for tasks
- 🔍 **Filter Views** - Filter tasks by All, Active, or Completed
- 💾 **Export/Import** - Export tasks as JSON and import from backups
- 🎨 **Beautiful UI** - Modern, responsive design with smooth animations
- 📱 **Responsive Design** - Works perfectly on desktop, tablet, and mobile

## 🚀 Quick Start

### Option 1: Open in Browser
```bash
# Simply open index.html in your browser
open todo-app/index.html
```

### Option 2: Use Local Server
```bash
# Using Python 3
python -m http.server 8000
# Then visit http://localhost:8000/todo-app/

# Using Node.js
npx http-server
# Then visit http://localhost:8080/todo-app/

# Using Live Server (VS Code extension)
# Right-click index.html and select "Open with Live Server"
```

## 📋 How to Use

### Adding a Task
1. Type your task in the input field
2. Press Enter or click "Add Task"
3. Task appears in your list

### Marking Complete
1. Click the checkbox next to a task
2. Task will be marked as completed with strikethrough
3. Automatically updates statistics

### Editing a Task
1. Click the "Edit" button on any task
2. Modify the task text, priority, or due date
3. Click "Save" to confirm changes

### Filtering Tasks
- **All**: View all tasks
- **Active**: View only incomplete tasks
- **Completed**: View only completed tasks

### Managing Tasks
- **Clear Completed**: Remove all completed tasks
- **Delete All**: Remove all tasks (with confirmation)
- **Export**: Download all tasks as JSON file
- **Import**: Load tasks from a previously exported JSON file

## 💾 Local Storage

All tasks are automatically saved to your browser's local storage:
- Tasks persist when you close and reopen the browser
- Each browser/device stores its own task list
- Storage key: `cediapp_todos`
- Maximum storage typically 5-10MB

## 📊 Statistics

Real-time task statistics display:
- **Total Tasks**: Count of all tasks
- **Completed**: Count of finished tasks
- **Remaining**: Count of active tasks

## 🎨 UI Components

### Header
- Application title and subtitle
- Clear visual hierarchy

### Input Section
- Text input for new tasks
- Add button with gradient background
- Filter buttons for task views

### Task List
- Individual task items with:
  - Checkbox for completion status
  - Task text
  - Due date (if set)
  - Priority badge (High/Medium/Low)
  - Edit button
  - Delete button

### Action Buttons
- Clear Completed
- Delete All
- Export Tasks
- Import Tasks

## 🛠️ Technical Details

### Technologies Used
- **HTML5**: Semantic markup and structure
- **CSS3**: Modern styling with gradients and animations
- **JavaScript (ES6+)**: Object-oriented programming with classes
- **Local Storage API**: For data persistence
- **File API**: For import/export functionality

### Browser Compatibility
- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- IE11: ⚠️ Limited support (no ES6 features)

### Data Structure
```javascript
{
    id: 1691234567890,           // Unique identifier (timestamp)
    text: "Buy groceries",       // Task description
    completed: false,            // Completion status
    priority: "high",            // Priority level
    dueDate: "2024-08-15",       // Due date (optional)
    createdAt: "8/3/2024..."    // Creation timestamp
}
```

## 📁 File Structure

```
todo-app/
├── index.html       # Main HTML file
├── styles.css       # Styling and animations
├── script.js        # JavaScript logic
└── README.md        # Documentation
```

## ⌨️ Keyboard Shortcuts

- **Enter**: Add new task (when input is focused)
- **Tab**: Navigate between elements
- **Click**: Select checkboxes and buttons

## 🔐 Privacy & Security

- All data stored locally in your browser
- No data sent to any server
- No tracking or analytics
- Export/Import files are plain JSON
- Safe to use on any device

## 🎯 Use Cases

- **Daily Tasks**: Manage your daily todo list
- **Project Planning**: Organize project tasks by priority
- **Shopping Lists**: Track items to buy
- **Study Schedule**: Organize study topics with due dates
- **Work Tasks**: Manage work assignments
- **Personal Goals**: Track personal objectives

## 🚀 Future Enhancements

Potential features to add:
- 📂 Categories/Tags for organizing tasks
- 🔔 Browser notifications for due dates
- 📈 Task completion statistics and charts
- 🌙 Dark mode toggle
- 👥 Task sharing/collaboration
- ☁️ Cloud sync functionality
- 🔄 Recurring tasks
- ⏱️ Timer/Pomodoro integration
- 📝 Notes per task
- 🗂️ Multiple lists/projects

## 💡 Tips

1. **Regular Backups**: Export your tasks weekly for backup
2. **Organize by Priority**: Use priority levels to focus on important tasks
3. **Set Due Dates**: Help you stay on track with deadlines
4. **Clear Completed**: Keep your list focused by removing done tasks
5. **Use Filters**: Switch between views to focus on active tasks

## 🐛 Troubleshooting

### Tasks Not Saving
- Check if local storage is enabled in browser
- Clear browser cache if experiencing issues
- Try exporting tasks to backup before clearing data

### Import Not Working
- Ensure JSON file is properly formatted
- Use files exported from this application
- Check browser console for error messages

### Storage Full
- Clear completed tasks to free up space
- Export old tasks to backup files
- Delete unnecessary tasks

## 📞 Support

For issues or suggestions:
- Check browser console for error messages
- Verify JSON file format for import
- Ensure local storage is not disabled

## 📄 License

This application is open source and free to use.

---

**Start organizing your tasks today! 🎉**
