# CheckMyGrade Application

A console-based application for managing student grades, courses, and professors. This application provides functionality to evaluate and display students' grades based on their scores in various subjects.

## Features

- Student record management (add, delete, modify)
- Course management
- Professor management
- Grade tracking and reporting
- Secure user authentication
- Data persistence using CSV files
- Search and sort functionality
- Statistical reports

## Setup Instructions

1. Clone the repository
2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the application:
   ```bash
   python main.py
   ```

## Project Structure

- `main.py`: Main application entry point
- `student.py`: Student class implementation
- `course.py`: Course class implementation
- `professor.py`: Professor class implementation
- `grades.py`: Grades class implementation
- `login.py`: User authentication implementation
- `data_manager.py`: Data management and CSV operations
- `requirements.txt`: Project dependencies

## CSV Files

The application uses the following CSV files for data storage:
- `students.csv`: Student records
- `courses.csv`: Course information
- `professors.csv`: Professor details
- `login.csv`: User authentication data

## Testing

To run the tests:
```bash
pytest
```

## Requirements

- Python 3.8 or higher
- Dependencies listed in requirements.txt 