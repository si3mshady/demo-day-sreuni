# Use an official Python runtime as the base image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file to the working directory
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project directory to the working directory
COPY . .

# Expose the port that Streamlit runs on (default is 8501)
EXPOSE 8501

# Set the command to run when the container starts
CMD ["streamlit", "run", "--server.port", "8501", "app.py"]
