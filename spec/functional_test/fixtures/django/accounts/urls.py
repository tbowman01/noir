from django.urls import path
from registration.backends.default.views import RegistrationView
from registration.forms import RegistrationFormUniqueEmail

from . import views as account_views

urlpatterns = [
    path(
        "register/",
        RegistrationView.as_view(form_class=RegistrationFormUniqueEmail),
        name="registration_register",
    ),
    path(
        "edit/",
        account_views.edit_profile,
        name="edit_profile",
    ),
]
