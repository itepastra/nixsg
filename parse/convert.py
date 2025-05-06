import argparse
import markdown
from jinja2 import Environment, FileSystemLoader
import os


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate HTML from Markdown with a Jinja template."
    )
    parser.add_argument("template_file", help="Path to the Jinja template file")
    parser.add_argument("markdown_file", help="Path to the markdown file")

    # This will capture any number of --key value arguments
    parser.add_argument(
        "template_values",
        nargs=argparse.REMAINDER,
        help="Key-value pairs to pass to the template in the form --key value",
    )

    return parser.parse_args()


def convert_markdown_to_html(markdown_file):
    with open(markdown_file, "r") as f:
        markdown_content = f.read()
    return markdown.markdown(markdown_content)


def parse_template_values(template_values):
    values = {}
    for i in range(0, len(template_values), 2):
        key = template_values[i].lstrip("--")  # Remove the '--' prefix
        value = template_values[i + 1] if i + 1 < len(template_values) else ""
        values[key] = value
    return values


def render_template(template_file, template_values, html_content):
    # Ensure the template directory exists or is correctly set
    template_dir = (
        os.path.dirname(template_file) if os.path.exists(template_file) else "templates"
    )

    env = Environment(
        loader=FileSystemLoader(template_dir)
    )  # Load the template from the specified directory
    template = env.get_template(
        os.path.basename(template_file)
    )  # Get the template by filename
    return template.render(content=html_content, **template_values)


def main():
    args = parse_args()

    # Convert markdown content to HTML
    html_content = convert_markdown_to_html(args.markdown_file)

    # Parse the arbitrary template values passed via command-line
    template_values = parse_template_values(args.template_values)

    # Render the template with the markdown content and additional values
    output_html = render_template(args.template_file, template_values, html_content)

    # Write the output to a file
    with open("output.html", "w") as f:
        f.write(output_html)

    print("HTML file generated successfully!")


if __name__ == "__main__":
    main()
