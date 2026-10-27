from django.contrib.auth import authenticate, login, logout
from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth.models import User


def login_page(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        if not User.objects.filter(username=username).exists():
            messages.error(request, 'Usuário inválido')
            return redirect('/login/')

        user = authenticate(username=username, password=password)

        if user is None:
            messages.error(request, 'Senha inválida')
            return redirect('/login/')
        else:
            login(request, user)
            return redirect('/members/')
    return render(request, 'login.html')


def logout_page(request):
    logout(request)
    messages.info(request, "Você saiu do sistema.")
    return redirect('/login/')


def register_page(request):
    if request.method == 'POST':
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = User.objects.filter(username=username)

        if user.exists():
            messages.error(request, "Usuário já existe!")
            return redirect('/register/')

        user = User.objects.create_user(
            first_name=first_name,
            last_name=last_name,
            username=username
        )

        user.set_password(password)
        user.save()

        messages.info(request, "Usuáro registrado com sucesso!")
        return redirect('/register/')

    return render(request, 'register.html')


def password_page(request):
    if request.method == "POST":
        password = request.POST.get('actual_password')
        if authenticate(username=request.user.username, password=password):
            p1 = request.POST.get('new_password')
            p2 = request.POST.get('repeated_password')
            if p1 == p2:
                request.user.set_password(p1)
                request.user.save()
                messages.info(request, "Senha alterada com sucesso.")
            else:
                messages.error(request, "Senhas não coincidem.")
        else:
            messages.error(request, "Senha atual não é válida.")
        return redirect('/change_password')
    else:
        return render(request, 'password.html')