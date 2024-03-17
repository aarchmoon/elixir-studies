defmodule Exercise do
  use Application

  def start(_type, _args) do
    Exercise.main()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def main() do
    student_list = []
    display_menu(student_list)
  end

  # Display the main menu.
  # Since Elixir does not provide any loops with "for" or "while", I had to do a recursive approach by using this function at the end of every other function to display again. Crazy stuff!
  def display_menu(student_list) do
    IO.puts("===== MENU ======")
    IO.puts("1. Add Student
2. Search by Student Name
3. Delete a student
4. List all students registered
5. Edit a student data
6. Exit")
    choice = IO.gets("Select an option: ") |> String.trim()
    choice = String.to_integer(choice)

    case choice do
      1 -> add_student(student_list)
      2 -> search_student(student_list)
      3 -> delete_student(student_list)
      4 -> list_all(student_list)
      5 -> edit_student(student_list)
      6 -> exit_program()
    end
  end

  # Add a student to the list, easy stuff.
  # Note to self: Do not use ++, Elixir documentation recommends using | to prepend the values. In the name of perfomance.
  def add_student(student_list) do
    name = IO.gets("Insert the name: ") |> String.trim()
    registration = IO.gets("Insert the registration: ") |> String.trim()
    course = IO.gets("Insert the course: ") |> String.trim()
    date_of_birth = IO.gets("Insert the date of birth: ") |> String.trim()

    student_tuple = {name, registration, course, date_of_birth}
    student_list = student_list ++ [student_tuple]

    IO.puts("The student was sucessfully registered.")
    display_menu(student_list)
  end

  # Search a student in the list. I thought that by inserting a tuple inside a list I would have been in trouble, but Elixir Enum functions rock!
  def search_student(student_list) do
    student_name = IO.gets("Insert the name of the student to search: ") |> String.trim()

    case Enum.find(student_list, fn {name, _reg, _course, _dob} -> name == student_name end) do
      nil ->
        IO.puts("Unable to find student.")

      {name, reg, course, dob} ->
        IO.puts("Student found: #{name}, Registration: #{reg}, Course: #{course}, DOB: #{dob}")
    end

    display_menu(student_list)
  end

  # Delete a student entry. One of the most difficult ones because I didn't know you could put two functions in a case statement. Also, having to return the values almost broke my hands... And my back.
  def delete_student(student_list) do
    student_reg = IO.gets("Insert the register of the student to delete: ") |> String.trim()

    student_index =
      Enum.find_index(student_list, fn {_name, reg, _course, _dob} -> reg == student_reg end)

    student_list =
      case Enum.find(student_list, fn {_name, reg, _course, _dob} -> reg == student_reg end) do
        nil ->
          IO.puts("Unable to find student.")
          student_list

        _ ->
          IO.puts("Entry sucessfully deleted.")
          List.delete_at(student_list, student_index)
      end

    display_menu(student_list)
  end

  # List all of the students. Ironically, the most difficult part was to redo this function to also display the student index,
  # since Elixir doesn't allow you to make a variable and increment its value in a for-loop way, because all of them are immutables. Damn.
  def list_all(student_list) do
    list_len = length(student_list)

    case list_len do
      0 ->
        IO.puts("There are no students registered.")

      _ ->
        Enum.with_index(student_list)
        |> Enum.each(fn {{name, reg, course, dob}, index} -> IO.puts("Listing all students.
=======
Student: #{index + 1}
Name: #{name}
Register: #{reg}
Course: #{course}
DOB: #{dob}") end)
    end

    display_menu(student_list)
  end

  # Edit the student entry. I had a lot of trouble doing this function in specific, so much so that I had to create update_data() to return a tuple.
  # I couldn't do all of this in one go, but whatever.
  def edit_student(student_list) do
    student_reg =
      IO.gets("Insert the register of the student to be edited: ") |> String.trim()

    student_index =
      Enum.find_index(student_list, fn {_name, reg, _course, _dob} -> reg == student_reg end)

    student_list =
      case Enum.find(student_list, fn {_name, reg, _course, _dob} -> reg == student_reg end) do
        nil ->
          IO.puts("The student couldn't be found.")
          student_list

        _ ->
          List.replace_at(student_list, student_index, update_data())
      end

    display_menu(student_list)
  end

  def update_data() do
    name = IO.gets("Insert the name: ") |> String.trim()
    registration = IO.gets("Insert the registration: ") |> String.trim()
    course = IO.gets("Insert the course: ") |> String.trim()
    date_of_birth = IO.gets("Insert the date of birth: ") |> String.trim()

    IO.puts("The student was sucessfully edited.")
    _student_tuple = {name, registration, course, date_of_birth}
  end

  # Exit program. Simple.
  def exit_program() do
    IO.puts("Thanks for using my program!")
    System.stop(1)
  end
end
