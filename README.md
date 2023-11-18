# Assignment Title - Flutter App with Back4App Integration

Create a flutter app that cnnects to Back4App, a Backend-as-a-service (BAAS)
platform to manage tasks

## Getting Started
# Step 1 - Setup Back4App

1. Sign up a Back4App account
1. Create a class names Tasks with columns
    - Title
   - Description
   - Status

>Back4App Dashboard
<img src="screenshots/Back4App_Account_Class.jpg" width="700">

# Step 2

- Create a new flutter project - cpad_assignmnt_task_app
- Add required dependencies to the pubspec.yaml.file

<img src="screenshots/pubspec_yaml.jpg" width="700">


# Application Details

The tasks application is made of 3 pages
- Home Page
- Task Detail page
- Create new task page

Tasks are saved in Back4App and are fetched from the same

>Home Page

Home Page consists of list of tasks, checkboxes on each task to check when complete
Every task has a delete button to delete any tasks from the database

<img src="screenshots/App_Homepage.jpg" width="300">


>Task Detail Page

On clicking on any individual task, we are directed to the details page which includes the title, detailed decription, creation date and the status of the task

<img src="screenshots/App_TaskDetailPage.jpg" width="300">

> New Task page

On this page, user is able to create tasks which get saved to the database. By default the status is false.

<img src="screenshots/App_NewTaskPage.jpg" width="300">


This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
