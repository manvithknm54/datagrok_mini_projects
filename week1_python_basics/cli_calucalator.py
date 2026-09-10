details={}

def total_calc(x):
    sum=0
    for i in x.values():
        sum=sum+i
    return sum

def grade_calc(y):
    avg=total_calc(y)/len(y)
    if avg>=85:
        return "Excellent"
    elif avg>=75:
        return "Strong Performance"
    elif avg>=60:
        return "On Track"
    else:
        return "Revisit"

while(1):
    print('''
    Welcome to Grade Calucalator as a admin you have these options:
    1.Add details of a student
    2.Delete the details of a student
    3.View the details of a single student or all the students present
    4.Exit
    ''')
    try:
        n=int(input("Enter you choice: "))
    except ValueError:
        print("Enter a valid number!")
        continue

    match n:
        case 1:
            marks={}
            print("Enter the details of the student that you would like to add")
            name = input("Enter the student name: ")
            try:
                subs= int(input("Enter the number of subjects whose details you have to enter: "))
                for i in range(subs):
                    subname=input("Enter the name of the subject: ")
                    submarks=int(input(f"Enter the marks obtained in {subname}: "))
                    marks[subname]=submarks
                details[name]=marks
                print("Details have been entered")
            except ValueError:
                print("Marks and subject count should be numbers! Student not added.")

        case 2:
            name=input("Enter the name of student whose details you would like to delete.")
            try:
                delchoice=input(f"You have choose {name} student details to delete are you sure you want to delete? yes or no: ")
                match delchoice:
                    case 'yes':
                        del details[name]
                        print("Deleted!")
                    case 'no':
                        print("You have choose not to delete the students detail!")
            except KeyError:
                print(f"No student named {name} found!")

        case 3:
            if len(details)==0:
                print("There is no details of the students!!")
            else:
                print('''Choose one of the options
                                1.A single user details
                                2.View everyones detail''')
                try:
                    viewchoice=int(input("Enter your choice: "))
                except ValueError:
                    print("Invalid input")
                    continue

                match viewchoice:
                    case 1:
                        name=input("Enter the details of the student whos report you have to view: ")
                        try:
                            print(f"Detailed View of {name}'s report")
                            for i,j in details[name].items():
                                print(f"Marks obtained in {i} subject is {j}")
                            print(f"Total obtained by {name} overall is: {total_calc(details[name])}")
                            print(f"The Grade the student {name} obtained is: {grade_calc(details[name])}")
                        except KeyError:
                            print(f"No student named {name} found!")
                    case 2:
                        print("All the details present in the dashboard: ")
                        for i,j in details.items():
                            print(f"The details of {i}'s is as follows: ")
                            for k,l in j.items():
                                print(f"Marks obtained in {k} subject is {l}")
                            print(f"Total: {total_calc(j)}  Grade: {grade_calc(j)}")
                    case _:
                        print("Invalid input")
        case 4:
            break
        case _:
            print("Invalid choice")