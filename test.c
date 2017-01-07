#include <stdio.h>
#include <stdlib.h>

#define RED 'r'
#define GREEN 'g'
#define BLUE 'b'
#define YELLOW 'y'

struct kula_t {
    int x, y, z, r;
    char color;
};

extern void sztokfisz (struct kula_t **spheres, char *bitmap, int height, int width, int count);

void usage() {
    printf("Usage: ./test test_file.txt\n");
}

char * readData(const char * filename, int * count, int *width, int *height, struct kula_t ***spheres) {
    FILE * file = fopen(filename, "r");
	int i, j, c, max_x = 0, max_y = 0;
    char * bitmap;
    struct kula_t* temp;
    if (file != NULL) {
        fscanf(file, "%d %d %d", count, width, height);
        c = fgetc(file);
        *spheres = (struct kula_t **) malloc(sizeof(struct kula_t *) * (*count));
        for (i = 0; i < *count; i++) {
            (*spheres)[i] = malloc(sizeof(struct kula_t));
            temp = (*spheres)[i];
            fscanf(file, "%d %d %d %d %c", &temp->x, &temp->y, &temp->z, &temp->r, &temp->color);
            c = fgetc(file);
        }
        bitmap = (char *) malloc((*width) * (*height) * sizeof(int));
        for (i = 0; i < (*width)*(*height); i++) {
            bitmap[i] = ' ';
	    }
		fclose(file);
        return bitmap;
	} else {
		fclose(file);
		printf("Error reading file\n");
        exit(1);
	}
}

const char * getPixel(char c) {
    switch(c) {
        case RED:
            return "\x1b[31m* ";
            break;
        case GREEN:
            return "\x1b[32m* ";
            break;
        case BLUE:
            return "\x1b[34m* ";
            break;
        case YELLOW:
            return "\x1b[33m* ";
            break;
        default:
            return "  "; 
    }
}

void printBitmap(char * bitmap, int width, int height) {
    int i,j;
    for (i = 0; i < height; i++) {
		for (j = 0; j < width; j++) {
			printf("%s", getPixel(bitmap[i * width + j]));		
		}
		printf("\n");
	}
}

int main(int argc, const char* argv[]) {
    int width, height, count;
    struct kula_t ** spheres;
    char * bitmap;
    if (argc < 2) {
        usage();
    } else {
        bitmap = readData(argv[1], &count, &width, &height, &spheres);
        sztokfisz(spheres, bitmap, height, width, count);
        printBitmap(bitmap, width, height);
    }
}
