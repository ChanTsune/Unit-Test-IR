from jinja2 import Template, Environment, FileSystemLoader


class TestRender:

    def __init__(self, test_object, lang_papper):
        self.test_object = test_object
        self.lang_papper = lang_papper

    def render(self, template_name, context, template_dir=''):
        self.env = Environment(loader=FileSystemLoader(template_dir))
        return self.env.get_template(template_name).render(context)
