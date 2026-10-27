from django.http import HttpResponse, HttpResponseRedirect
from django.template import loader
from django.urls import reverse
from .models import Member
from plans.models import Plan
from django.db.models import Q
from django.core.paginator import Paginator
from django.contrib.auth.decorators import login_required
from django.contrib import messages       # ← adicionar
from django.shortcuts import redirect     # ← adicionar

@login_required(login_url="/login/")
def members(request):
    if not request.user.is_superuser and not request.user.groups.filter(name='secretaria').exists():
        messages.error(request, "Permissão negada")
        return redirect('/')

    mymembers = Member.objects.all()
    template = loader.get_template('all_members.html')

    paginator = Paginator(mymembers, 2)
    page_number = request.GET.get("page")
    page_obj = paginator.get_page(page_number)

    context = {
        'mymembers': mymembers,
        "page_obj": page_obj,
    }
    return HttpResponse(template.render(context, request))

@login_required(login_url="/login/")
def details(request, id):
    mymember = Member.objects.get(id=id)
    template = loader.get_template('details.html')
    context = {
        'mymember': mymember
    }
    return HttpResponse(template.render(context, request))

def main(request):
    template = loader.get_template("main.html")
    return HttpResponse(template.render({}, request))

@login_required(login_url="/login/")
def add(request):
    myplans = Plan.objects.all().values()
    template = loader.get_template('add.html')
    context = {
        'myplans':myplans,
    }
    return HttpResponse(template.render(context, request))

@login_required(login_url="/login/")
def addrecord(request):
    x = request.POST['first']
    y = request.POST['last']
    z = Plan.objects.filter(id=request.POST['plan']).first()
    foto = None
    if 'foto' in request.FILES:
        foto = request.FILES['foto']
    if 'documento' in request.FILES:
        documento = request.FILES['documento']
    member = Member(firstname=x, lastname=y, plan=z, foto=foto, documento=documento)
    member.save()
    return HttpResponseRedirect(reverse('members'))

@login_required(login_url="/login/")
def delete(request, id):
    member = Member.objects.get(id=id)
    member.delete()
    return HttpResponseRedirect(reverse('members'))

@login_required(login_url="/login/")
def update(request, id):
    mymember = Member.objects.get(id=id)
    myplans = Plan.objects.all().values()
    template = loader.get_template('update.html')
    context = {
        'mymember': mymember,
        'myplans': myplans
    }
    return HttpResponse(template.render(context, request))

@login_required(login_url="/login/")
def updaterecord(request, id):
    first = request.POST['first']
    last = request.POST['last']
    plan = request.POST['plan']
    member = Member.objects.get(id=id)
    member.firstname = first
    member.lastname = last
    member.plan = Plan.objects.get(id=plan)
    if 'foto' in request.FILES:
        foto = request.FILES['foto']
        member.foto = foto
    if 'documento' in request.FILES:
        documento = request.FILES['documento']
        member.documento = documento    
    member.save()
    return HttpResponseRedirect(reverse('members'))
