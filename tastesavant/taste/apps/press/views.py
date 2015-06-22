from django.shortcuts import render
from .models import PressBadge


def show_press(request):
    data = {
        'badges': PressBadge.objects.all(),
    }
    return render(request, 'press/press.html', data)
