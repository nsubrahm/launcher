import argparse
import json

from config import ConfigurationManager
from environ import EnvironmentFilesGenerator

def main():
  try:
    parser = argparse.ArgumentParser(description="Read configuration values from a file.")
    parser.add_argument("-f", "--file", default="config.json", help="Path to the configuration file.")
    args = parser.parse_args()

    config_manager = ConfigurationManager(args.file)
    config_values = config_manager.get_config_values()
    e = EnvironmentFilesGenerator(config_values)
    e.generate_env_files()
    e.copy_env_files()

  except FileNotFoundError as e:
    print(f"Error: File error - {e}")
  except json.JSONDecodeError as e:
    print(f"Error: Failed to decode JSON - {e}")
  except Exception as e:
    print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
  main()
