package com.exemple.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Inscription extends HttpServlet {
    public static final String VUE = "/WEB-INF/inscription.jsp";
    public static final String CHAMP_EMAIL = "email";
    public static final String CHAMP_PASS = "motdepasse";
    public static final String CHAMP_CONF = "confirmation";
    public static final String CHAMP_NOM = "nom";

    public static final String ATT_ERREURS = "erreurs";
    public static final String ATT_RESULTAT = "resultat";

    //------------------------------------------------------------------------------------------------------------------
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /* Affichage de la page d'inscription */
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }
    //------------------------------------------------------------------------------------------------------------------

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String resultat;
        Map<String, String> erreurs = new HashMap<String, String>();

        /* Récupération des champs du formulaire. */
        String email = request.getParameter(CHAMP_EMAIL);
        String motDePasse = request.getParameter(CHAMP_PASS);
        String confirmation = request.getParameter(CHAMP_CONF);
        String nom = request.getParameter(CHAMP_NOM);

        //------------------------------------- Validation du champ email. --------------------------------------------
        try {
            validationEmail(email);
        } catch (Exception e) {
            erreurs.put(CHAMP_EMAIL, e.getMessage());
        }

        //-------------------------- Validation des champs mot de passe et confirmation. ------------------------------
        try {
            validationMotsDePasse(motDePasse, confirmation);
        } catch (Exception e) {
            erreurs.put(CHAMP_PASS, e.getMessage());
        }

        //------------------------------------- Validation du champ nom. ----------------------------------------------
        try {
            validationNom(nom);
        } catch (Exception e) {
            erreurs.put(CHAMP_NOM, e.getMessage());
        }

        //----------------------- Initialisation du résultat global de la validation. ---------------------------------
        if (erreurs.isEmpty()) {
            resultat = "Succès de l'inscription.";
        } else {
            resultat = "Échec de l'inscription.";
        }

        //----------------- Stockage du résultat et des messages d'erreur dans l'objet request ------------------------
        request.setAttribute(ATT_ERREURS, erreurs);
        request.setAttribute(ATT_RESULTAT, resultat);

        /* Transmission de la paire d'objets request/response à notre JSP */
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }

    //------------------------------------------------------------------------------------------------------------------
    //                                   Valide l'adresse mail saisie.
    //------------------------------------------------------------------------------------------------------------------
    private void validationEmail(String email) throws Exception {
        if (email != null && email.trim().length() != 0) {
            if (!email.matches("([^.@]+)(\\.[^.@]+)*@([^.@]+\\.)+([^.@]+)")) {
                throw new Exception("Merci de saisir une adresse mail valide.");
            }
        } else {
            throw new Exception("Merci de saisir une adresse mail.");
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    //                                  Valide les mots de passe saisis.
    //------------------------------------------------------------------------------------------------------------------
    private void validationMotsDePasse(String motDePasse, String confirmation) throws Exception {
        if (motDePasse != null && motDePasse.trim().length() != 0 && confirmation != null && confirmation.trim().length() != 0) {
            if (!motDePasse.equals(confirmation)) {
                throw new Exception("Les mots de passe entrés sont différents, merci de les saisir à nouveau.");
            } else if (motDePasse.trim().length() < 3) {
                throw new Exception("Les mots de passe doivent contenir au moins 3 caractères.");
            }
        } else {
            throw new Exception("Merci de saisir et confirmer votre mot de passe.");
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    //                                Valide le nom d'utilisateur saisi.
    //------------------------------------------------------------------------------------------------------------------
    private void validationNom(String nom) throws Exception {
        if (nom != null && nom.trim().length() < 3) {
            throw new Exception("Le nom d'utilisateur doit contenir au moins 3 caractères.");
        }
    }
}
/*
La partie en charge de la récupération des champs du formulaire se situe aux lignes 24 à 27 : il s'agit tout simplement
d'appels à la méthode request.getParameter(). Il nous reste maintenant à implémenter nos trois dernières méthodes de
validation.

J'ai ici fait en sorte que dans chaque méthode, lorsqu'une erreur de validation se produit, le code envoie une exception
contenant un message explicitant l'erreur. Ce n'est pas la seule solution envisageable, mais c'est une solution qui a
le mérite de tirer parti de la gestion des exceptions en Java. À ce niveau, un peu de réflexion sur la conception de
notre système de validation s'impose :

Que faire de ces exceptions envoyées ?
**************************************

En d'autres termes, quelles informations souhaitons-nous renvoyer à l'utilisateur en cas d'erreur ? Pour un formulaire
d'inscription, a priori nous aimerions bien que l'utilisateur soit au courant du succès ou de l'échec de l'inscription,
et en cas d'échec qu'il soit informé des erreurs commises sur les champs posant problème.

Comment procéder ? Là encore, il y a bien des manières de faire. Je vous propose ici le mode de fonctionnement suivant :

une chaîne resultat contenant le statut final de la validation des champs ;

une Map erreurs contenant les éventuels messages d'erreur renvoyés par nos différentes méthodes se chargeant de la
validation des champs. Une HashMap convient très bien dans ce cas d'utilisation : en l'occurrence, la clé sera le nom
du champ et la valeur sera le message d'erreur correspondant.

------------------------------------------------------------------------------------------------------------------------

Analysez bien les modifications importantes du code, afin de bien comprendre ce qui intervient dans ce processus de
gestion des exceptions :

         * chaque appel à une méthode de validation d'un champ est entouré d'un bloc try/catch ;

         * à chaque entrée dans un catch, c'est-à-dire dès lors qu'une méthode de validation envoie une exception,
           on ajoute à la Maperreurs le message de description inclus dans l'exception courante, avec pour clé l'intitulé
           du champ du formulaire concerné ;

         * le message resultat contenant le résultat global de la validation est initialisé selon que la Maperreurs
           contient des messages d'erreurs ou non ;

         * les deux objets erreurs et resultat sont enfin inclus en tant qu'attributs à la requête avant l'appel final
           à la vue.

Le contrôle des données dans notre servlet est maintenant fonctionnel : avec les données que nous transmettons à notre
JSP, nous pouvons y déterminer si des erreurs de validation ont eu lieu et sur quels champs.
*/
