#use python image
FROM python:3.10-slim

# Set the working directory
WORKDIR /app

#copy files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

#Expose Flask port
EXPOSE 5000

#Run with gunicorn
CMD ["gunicorn", "-b","0.0.0.0:5000","app.app"]