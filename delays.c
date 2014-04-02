/* Program określa parametry wywołania procedury delay2 w zależności od wymaganego opóźnienia i
 * dopuszczalnego odchylenia. Użycie:
 *
 *./delays <liczba cykli opóźnienia> <maksymalne odchylenie (cykle)>
 * Przykład:
 * $ ./delays 2199991 5
 * > des_cyc: 2199991, des_delta: 5
 * > DELAY_X: 136, DELAY_Y: 134, W: 12 || CYCLES: 2199988, DELTA: 3
 * > DELAY_X: 121, DELAY_Y: 7, W: 233 || CYCLES: 2199990, DELTA: 1
 * > DELAY_X: 11, DELAY_Y: 85, W: 233 || CYCLES: 2199990, DELTA: 1
 *  * DELAY_X, DELAY_Y, W – parametry wywołania procedury delay2
 *  * CYCLES – liczba cykli zużytych w prcoedurze delay2 dla danych parametrów
 *  * DELTA – liczba cykli jaką należy zużyć po wywołaniu procedury aby osiągnąć oczekiwane opoźnienie
 **/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_C	(255*255*255)

typedef struct {
	unsigned char X, Y, C;
	int delta;
} result;

static int comp(const void *a, const void *b) {
	return ((const result*)a)->delta - ((const result*)b)->delta;
}

int main(int argc, char **argv) {
	if ((argc < 3) || (! strcmp(argv[1], "-h"))) {
		printf("Użycie: ./delays [oczekiwana liczba cykli] [maksymalne odchylenie (cykle)]\n");
		return 0;
	}
	result *res = malloc(MAX_C * sizeof(result));
	int des_cyc, des_delta, delta, cyc;
	unsigned int res_i = 0;
	unsigned short X, Y, C;
	
	sscanf(argv[1], "%d", &des_cyc);  
	sscanf(argv[2], "%d", &des_delta);
	
	printf("des_cyc: %d, des_delta: %d\n", des_cyc, des_delta);
	
	for (X = 0; X <= 255; X++) {
		for (Y = 0; Y <= 255; Y++) {
			for (C = 0; C <= 255; C++) {
				cyc = 4 + C * (4 + X*(8+10*Y));
				delta = des_cyc - cyc;
				if ((delta >= 0) && (delta < des_delta)) {
					res[res_i].X = X;
					res[res_i].Y = Y;
					res[res_i].C = C;
					res[res_i].delta = delta;
					res_i++;
				}
			}
		}
	}
	
	if (res_i) {
		qsort(res, res_i, sizeof(result), comp);
		res_i--;
		for (;; ) {
			printf("DELAY_X: %3d, DELAY_Y: %3d, W: %3d || CYCLES: %d, DELTA: %5d\n", res[res_i].X, res[res_i].Y, res[res_i].C, des_cyc - res[res_i].delta, res[res_i].delta);
			if (! res_i) break;
			res_i--;
		}
	}
	else printf("Brak wyników\n");
	free(res);
	return 0;
}
