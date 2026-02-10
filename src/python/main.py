# src/python/main.py
import os
import datetime


def main():
    who_to_greet = os.environ.get("INPUT_WHO_TO_GREET", "World")
    print(f"Hello, {who_to_greet}!")

    time = datetime.datetime.utcnow().isoformat() + "Z"
    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
        f.write(f"time={time}\n")


if __name__ == "__main__":
    main()
