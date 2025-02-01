import os
from jinja2 import Environment, FileSystemLoader

class EnvironmentFilesGenerator:
    def __init__(self, configValues):
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
        
        print(f"Reading templates from {self.templateDir} and writing to {self.outputDir}")
        for template_file in os.listdir(self.templateDir):
          if template_file.endswith('.tmpl'):
            template = self.env.get_template(template_file)
            output_content = template.render(**self.configValues)
            output_file_name = template_file.replace('.tmpl', '.env')
            output_file_path = os.path.join(self.outputDir, output_file_name)
            with open(output_file_path, 'w') as output_file:
                output_file.write(output_content)
            print(f"\tGenerated .env file {output_file_path} from template file {template_file}")
      except FileNotFoundError as f:
        raise f
      except Exception as e:
        raise e

