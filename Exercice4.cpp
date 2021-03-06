#include <iostream>
#include <fstream>
#include <cmath>
#include <iomanip>
#include <valarray>
#include <algorithm>
#include "ConfigFile.tpp" // Fichier .tpp car inclut un template

using namespace std;

const double G(6.674*pow(10,-20));

//--------------------DEFINITIONS CLASSES----------------------------
class Exercice4{
	private:
			// Definitions variables
		double t,dt,tFin;
		double m1,m2,m3;
		double epsilon;
		bool adaptatif;
		valarray<double> Y;
		int sampling;
		int last;
		ofstream *outputFile;
		
			// PrintOut
		void printOut(bool force){
			if((!force && last>=sampling) || (force && last!=1)){
				energie();
				
				*outputFile << t << " ";
				
				
				for (size_t i(0); i<Y.size(); ++i){
					*outputFile << Y[i] << " ";
				}				
				*outputFile << energie() << endl;

				last=1;
			}else{
				last++;
			}
		};
		
			// Fonction qui calcule l'énergie
		double energie(){ 
			double Epot1, Epot3;
			double Ecin1, Ecin2, Ecin3;
			double Epot, Ecin;
			
			Epot1= G*m1*m2/(dist(Y[0], Y[2], Y[1], Y[3]));
			Epot3= G*m1*m3/(dist(Y[0], Y[4], Y[1], Y[5])) + G*m2*m3/(dist(Y[2], Y[4], Y[3], Y[5]));
			Epot=Epot1+Epot3;
			
			Ecin1= 0.5*m1*(pow(Y[6],2.)+pow(Y[7],2.));
			Ecin2= 0.5*m1*(pow(Y[8],2.)+pow(Y[9],2.));	
			Ecin3= 0.5*m1*(pow(Y[10],2.)+pow(Y[11],2.));	
			Ecin= Ecin1+ Ecin2 +Ecin3;
			
			return Epot+Ecin;
		}
		
			// Fonctions necessaires pour la fonction step()
		valarray<double> acceleration(valarray<double> y){
			valarray<double> f; f.resize(12);
			
			/* On calcule chaque terme à la main car la fonction slice nous donne
			 * un poroblème d'allocation de la memoire
			 * */
			
			if ((m1==0) || (m2==0) || (m3==0)) {		// si un des 3 masse est 0, on calcule ainsi
				f[0] = y[6];
				f[1] = y[7];
				f[2] = y[8];
				f[3] = y[9];
				f[4] = 0.;
				f[5] = 0.;
				f[6] = G*m2*(y[2]-y[0])/(pow(dist(y[0], y[2], y[1], y[3]),3));
				f[7] = G*m2*(y[3]-y[1])/(pow(dist(y[0], y[2], y[1], y[3]),3));
				f[8] = G*m1*(y[0]-y[2])/(pow(dist(y[0], y[2], y[1], y[3]),3));
				f[9] = G*m1*(y[1]-y[3])/(pow(dist(y[0], y[2], y[1], y[3]),3));
				f[10] = 0;
				f[11] = 0;
			} else {
				f[0] = y[6];
				f[1] = y[7];
				f[2] = y[8];
				f[3] = y[9];
				f[4] = y[10];
				f[5] = y[11];
				f[6] = G*m2*(y[2]-y[0])/(pow(dist(y[0], y[2], y[1], y[3]),3)) +  G*m3*(y[4]-y[0])/(pow(dist(y[0], y[4], y[1], y[5]),3));	// acceleration sur x de la masse 1
				f[7] = G*m2*(y[3]-y[1])/(pow(dist(y[0], y[2], y[1], y[3]),3)) +  G*m3*(y[5]-y[1])/(pow(dist(y[0], y[4], y[1], y[5]),3));	// acceleration sur y de la masse 1
				f[8] = G*m1*(y[0]-y[2])/(pow(dist(y[0], y[2], y[1], y[3]),3)) +  G*m3*(y[4]-y[2])/(pow(dist(y[2], y[4], y[3], y[5]),3));	// acceleration sur x de la masse 2
				f[9] = G*m1*(y[1]-y[3])/(pow(dist(y[0], y[2], y[1], y[3]),3)) +  G*m3*(y[5]-y[3])/(pow(dist(y[2], y[4], y[3], y[5]),3));	// acceleration sur y de la masse 2
				f[10] = G*m1*(y[0]-y[4])/(pow(dist(y[4], y[0], y[5], y[1]),3)) +  G*m2*(y[2]-y[4])/(pow(dist(y[4], y[2], y[3], y[5]),3));	// acceleration sur x de la masse 3
				f[11] = G*m1*(y[1]-y[5])/(pow(dist(y[0], y[4], y[1], y[5]),3)) +  G*m2*(y[3]-y[5])/(pow(dist(y[4], y[2], y[5], y[3]),3));	// acceleration sur y de la masse 3
			}
			return f;
		}
		
		double dist(double x1, double x2, double y1, double y2){
			double d(sqrt(pow(x1-x2,2.) + pow(y1-y2,2.)));
			if (d == 0) {
				//cout << "Division par zero dans la distance!!" << endl;
				return 1;
			}	
			return d;
		}
		
			// step() pour Runge-Kutta 4
		void step(valarray<double> &y, double deltat){
			valarray<double> k1; k1.resize(12);
			valarray<double> k2; k2.resize(12);
			valarray<double> k3; k3.resize(12);
			valarray<double> k4; k4.resize(12);
			
			k1 = deltat*acceleration(y);
			k2 = deltat*acceleration(y + 0.5*k1);
			k3 = deltat*acceleration(y + 0.5*k2);
			k4 = deltat*acceleration(y + k3);
			y = y + (k1 + 2.*k2 + 2.*k3 + k4)/6.;
		}
		
			// restitue le max
		double maximum(double a, double b, double c){
			if(a>=b && a>=c){
				return a;
			} else { if (b>=a && b>=c){
				return b;
			} else { 
				return c;
			}
			}
		}
		
	
	public:
			// Constructeur Exercice4
		Exercice4(int argc, char* argv[])
		:Y(12)
		{
    
			string inputPath("configuration.in"); // Fichier d'input par defaut
			if(argc>1) // Fichier d'input specifie par l'utilisateur ("./Exercice4 config_perso.in")
				inputPath = argv[1];

				ConfigFile configFile(inputPath); // Les parametres sont lus et stockes dans une "map" de strings.

				for(int i(2); i<argc; ++i) // Input complementaires ("./Onde config_perso.in input_scan=[valeur]") argc a ete enleve temporairement
				configFile.process(argv[i]);
				
				tFin     = configFile.get<double>("tFin");
				dt       = configFile.get<double>("dt");
				m1       = configFile.get<double>("m1");
				m2       = configFile.get<double>("m2");
				m3       = configFile.get<double>("m3");
				Y[0]     = configFile.get<double>("x01");
				Y[1]     = configFile.get<double>("y01");
				Y[2]     = configFile.get<double>("x02");
				Y[3]     = configFile.get<double>("y02");
				Y[4]     = configFile.get<double>("x03");
				Y[5]     = configFile.get<double>("y03");
				Y[6]     = configFile.get<double>("vx01");
				Y[7]     = configFile.get<double>("vy01");
				Y[8]     = configFile.get<double>("vx02");
				Y[9]     = configFile.get<double>("vy02");
				Y[10]    = configFile.get<double>("vx03");
				Y[11]    = configFile.get<double>("vy03");
				sampling = configFile.get<int>("sampling");
				epsilon  = configFile.get<double>("epsilon");
    
			// Ouverture du fichier de sortie
		
			outputFile = new ofstream(configFile.get<string>("output").c_str());
			outputFile->precision(15);
				
				int n;
				bool sortir;
				do {
					cout << "Utiliser le pas de temps adaptatif (1 si oui, 0 sinon)? " ;
					cin >> n;
					
					if (n==0) {
						adaptatif = false;
						sortir = false;
						cout << "Choisi: pas de temps fixe" << endl;
					} else if (n==1) {
						adaptatif = true;
						sortir = false;
						cout << "Choisi: pas de temps adaptatif" << endl;
					} else {
						sortir = true;
						cout << "Le choi a faire est soit 0 soit 1" << endl;
					}
				} while (sortir);
		};
		
			// Destructeur  
		~Exercice4(){
			outputFile->close();
			delete outputFile;
		};
		
			// run()
		void run(){
			last = 0;
			t = 0;
			printOut(true);
			
			while(t<tFin) {
				step(Y, dt);
				
				if (adaptatif){
					valarray<double> Yprim(Y);
					double d1, d2, d3, d ;
					
					step(Yprim, dt*0.5);
					step(Yprim, dt*0.5);
						
					d1 = sqrt(pow(Y[0]-Yprim[0],2) + pow(Y[1]-Yprim[1],2));	
					d2 = sqrt(pow(Y[2]-Yprim[2],2) + pow(Y[3]-Yprim[3],2));	
					d3 = sqrt(pow(Y[4]-Yprim[4],2) + pow(Y[5]-Yprim[5],2));
					
					d = maximum(d1, d2, d3);
					
					if (d<epsilon){
						dt = dt * pow(epsilon/d,1./5.);
						dt = min(tFin-t, dt);							// permet de ne pas dépasser tFin
					} else { 
						do {	
						dt = 0.99 * dt * pow(epsilon/d,1./5.);
						dt = min(tFin-t, dt);							// permet de ne pas dépasser tFin
						
						step(Y, dt);
						step(Yprim, dt*0.5);
						step(Yprim, dt*0.5);
						
						d1 = sqrt(pow(Y[0]-Yprim[0],2) + pow(Y[1]-Yprim[1],2));	
						d2 = sqrt(pow(Y[2]-Yprim[2],2) + pow(Y[3]-Yprim[3],2));	
						d3 = sqrt(pow(Y[4]-Yprim[4],2) + pow(Y[5]-Yprim[5],2));
						
						} while (d > epsilon);
					}
				}
				t += dt;
				printOut(false);
				
				if(t>tFin){	// Permet de sauvgarder les differentes valeurs au temps tFin
					if(adaptatif){
						// À COMPLETER: pour le temps finale pour le dt adaptatif
					} else {
						t = tFin;
						step(Y, dt);
						printOut(true);
					}
				}
				
			}
			//printOut(true);
			
		};
		
};

//-------------------------------MAIN----------------------------------
int main(int argc, char* argv[]) 
{
  Exercice4 planete(argc, argv);
  planete.run();
  return 0;
}
