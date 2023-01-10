from django.db import models

# Create your models here.
class Todo(models.Model):
    title = models.CharField(max_length=30)
    desc = models.CharField(max_length=200)
    isDone = models.BooleanField(default=True)
    date = models.DateField(auto_now_add=True)

    def __str__(self) -> str:
        return self.title[:20]