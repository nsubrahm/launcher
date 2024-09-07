import os
from jinja2 import Environment, FileSystemLoader

class EnvironmentFilesGenerator:
    def __init__(self, configValues):
      self.sourceDir = configValues['sourceDir']
      self.templateDir = configValues["templateDir"]
      self.outputDir = configValues["outputDir"]
      self.configValues = configValues
      self.env = Environment(loader=FileSystemLoader(self.templateDir))
        
    def check_folder_exists(self, folder_path):
      if not os.path.exists(folder_path):
        raise FileNotFoundError(f"Folder does not exist: {folder_path}")

    def generate_env_files(self):
      try:
        self.check_folder_exists(self.templateDir)
        self.check_folder_exists(self.outputDir)
        
        print(f"Reading templates from: {self.templateDir}")
        print(f"Will write to {self.outputDir}")
        for template_file in os.listdir(self.templateDir):
          if template_file.endswith('.tmpl'):
            print(f"Processing template file: {template_file}")
            template = self.env.get_template(template_file)
            output_content = template.render(**self.configValues)
            output_file_name = template_file.replace('.tmpl', '.env')
            output_file_path = os.path.join(self.outputDir, output_file_name)
            with open(output_file_path, 'w') as output_file:
                output_file.write(output_content)
            print(f"Generated .env file: {output_file_path}")
      except FileNotFoundError as f:
        raise f
      except Exception as e:
        raise e

    def copy_env_files(self):
      try:
        self.check_folder_exists(self.sourceDir)
        self.check_folder_exists(self.outputDir)
        print(f"Copying from {self.sourceDir} to {self.outputDir}")
        
        for file in os.listdir(self.sourceDir):
          if file.endswith('.env'):
            source_file_path = os.path.join(self.sourceDir, file)
            target_file_path = os.path.join(self.outputDir, file)
            with open(source_file_path, 'r') as source_file:
                content = source_file.read()
            with open(target_file_path, 'w') as target_file:
                target_file.write(content)
            print(f"Copied .env file from {source_file_path} to {target_file_path}")
      except FileNotFoundError as f:
        raise f
      except Exception as e:
        raise e
