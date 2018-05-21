import sys
import time
import redis


def write_redis(redis_db, content):
    redis_db.set('watched content', content)

def read_redis(redis_db):
    return redis_db.get('watched content')

def read_in(file):
    with open(file, 'r') as myfile:
        content = myfile.read()

    return content


def check_changes(file, redis_db):

    while True:
        rediscontent = read_redis(redis_db)
        newcontent = bytes(read_in(file), 'utf-8')
        print("##### new content")
        print(newcontent)
        print("##### redis content")
        print(rediscontent)

        if newcontent == rediscontent:
            print("All same")
        else:
            print("something changed")
            write_redis(redis_db, newcontent)
        time.sleep(4)




if __name__ == "__main__":
    FILE = sys.argv[1]
    REDIS = sys.argv[2]
    REDIS_PORT = sys.argv[3]
    redis_db = redis.StrictRedis(host=REDIS, port=REDIS_PORT, db=0)

    check_changes(FILE, redis_db)
