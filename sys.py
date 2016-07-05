#!usr/bin/env python


def list(file_in):
    result = {}
    file_buffer = open(file_in, "r")
    for line in file_buffer.readlines():
        result[line.split("-")[0].strip()] = line.split("-")[1]
    file_buffer.close()

    return result


def format(result_list):
    for program in result_list:
        for part in result_list[program].strip().replace("\n", "").split(","):
            print(program.strip() + " " + part.strip())

if __name__ == '__main__':
    file_in = "./shell_commands"
    format(list(file_in))
